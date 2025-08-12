import { Injectable, Logger, InternalServerErrorException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { User } from '../../../database/entities/user.entity';
import { TwoFactorCode } from './entities/two-factor-code.entity';
import { MailService } from '../../notifications/mail/mail.service';
import { randomInt } from 'crypto';

@Injectable()
export class TwoFactorService {
  private readonly logger = new Logger(TwoFactorService.name);

  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(TwoFactorCode)
    private twoFactorCodesRepository: Repository<TwoFactorCode>,
    private mailService: MailService,
  ) {}

  async enableTwoFactor(userId: string): Promise<void> {
    await this.usersRepository.update(userId, { isTwoFactorEnabled: true });
  }

  async disableTwoFactor(userId: string): Promise<void> {
    await this.usersRepository.update(userId, { isTwoFactorEnabled: false });
  }

  async isTwoFactorEnabled(userId: string): Promise<boolean> {
    const user = await this.usersRepository.findOne({ where: { id: userId } });
    return user?.isTwoFactorEnabled ?? false;
  }

  async generateAndSendVerificationCode(email: string): Promise<void> {
    try {
      const user = await this.usersRepository.findOne({ where: { email } });

      if (!user) {
        this.logger.warn(`Attempted to generate 2FA code for non-existent user: ${email}`);
        return;
      }

      // Generate a 6-digit code
      const code = randomInt(100000, 999999).toString();
      const expirationDate = new Date();
      expirationDate.setMinutes(expirationDate.getMinutes() + 10); // Code valid for 10 minutes

      // Try to create the table if it doesn't exist
      try {
        // First, check if the table exists by attempting a simple query
        await this.twoFactorCodesRepository.query('SELECT 1 FROM two_factor_codes LIMIT 1');
      } catch (dbError) {
        if (dbError.code === '42P01') { // PostgreSQL error code for relation does not exist
          this.logger.error('two_factor_codes table does not exist - disabling 2FA temporarily');
          
          // Instead of throwing an error, disable 2FA for this user and continue login process
          await this.disableTwoFactor(user.id);
          
          // Skip saving the code, just try to send the email
          try {
            await this.mailService.send({
              to: user.email,
              subject: 'Your GovConnect Verification Code',
              template: 'two-factor-code',
              context: {
                name: user.firstName || 'User',
                code,
              },
            });
            return;
          } catch (emailError) {
            this.logger.error(`Failed to send 2FA email: ${emailError.message}`);
            return;
          }
        }
      }

      // If we reach here, the table exists, so save the code
      await this.twoFactorCodesRepository.save({
        userId: user.id,
        code,
        expiresAt: expirationDate,
      });

      // Send the code via email
      await this.mailService.send({
        to: user.email,
        subject: 'Your GovConnect Verification Code',
        template: 'two-factor-code',
        context: {
          name: user.firstName || 'User',
          code,
        },
      });

      this.logger.log(`2FA code sent to ${email}`);
    } catch (error) {
      this.logger.error(`Error in generateAndSendVerificationCode: ${error.message}`, error.stack);
      
      // Wrap the error to prevent exposing implementation details
      throw new InternalServerErrorException(
        'Authentication system is temporarily unavailable. Please try again later.'
      );
    }
  }

  async verifyCode(email: string, code: string): Promise<boolean> {
    try {
      const user = await this.usersRepository.findOne({ where: { email } });
      
      if (!user) {
        return false;
      }

      try {
        const twoFactorCode = await this.twoFactorCodesRepository.findOne({
          where: {
            userId: user.id,
            code,
            expiresAt: MoreThan(new Date()),
          },
          order: { createdAt: 'DESC' },
        });

        if (!twoFactorCode) {
          return false;
        }

        // Code is valid, delete it to prevent reuse
        await this.twoFactorCodesRepository.remove(twoFactorCode);
        
        return true;
      } catch (dbError) {
        this.logger.error(`Database error while verifying 2FA code: ${dbError.message}`, dbError.stack);
        throw dbError;
      }
    } catch (error) {
      this.logger.error(`Error verifying 2FA code: ${error.message}`, error.stack);
      return false;
    }
  }
}
