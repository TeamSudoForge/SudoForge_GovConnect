import { Injectable, Logger, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { User } from '../../../database/entities/user.entity';
import { EmailVerificationCode } from './entities/email-verification-code.entity';
import { MailService } from '../../notifications/mail/mail.service';
import { randomInt } from 'crypto';

@Injectable()
export class EmailVerificationService {
  private readonly logger = new Logger(EmailVerificationService.name);
  private readonly CODE_EXPIRY_MINUTES = 10;
  private readonly RESEND_DELAY_SECONDS = 45;

  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(EmailVerificationCode)
    private emailVerificationCodesRepository: Repository<EmailVerificationCode>,
    private mailService: MailService,
  ) {}

  private async checkUserRateLimit(userId: string): Promise<void> {
    const canSend = await this.canResendCode(userId);
    if (!canSend) {
      const remainingSeconds = await this.getRemainingDelaySeconds(userId);
      throw new ConflictException(`Please wait ${remainingSeconds} seconds before requesting another code`);
    }
  }

  async isEmailVerified(userId: string): Promise<boolean> {
    const user = await this.usersRepository.findOne({ where: { id: userId } });
    return user?.isEmailVerified ?? false;
  }

  async markEmailAsVerified(userId: string): Promise<void> {
    await this.usersRepository.update(userId, { isEmailVerified: true });
    // Clean up any existing verification codes for this user
    await this.emailVerificationCodesRepository
      .createQueryBuilder()
      .delete()
      .where('user_id = :userId', { userId })
      .execute();
  }


  async canResendCode(userId: string): Promise<boolean> {
    this.logger.log(`Checking if user ${userId} can resend verification code...`);
    try {
      const latestCode = await this.emailVerificationCodesRepository.findOne({
        where: { userId },
        order: { createdAt: 'DESC' },
      });
      
      if (!latestCode) {
        return true; // No previous code, can send
      }

      const timeDiff = Date.now() - latestCode.lastSentAt.getTime();
      const canResend = timeDiff >= this.RESEND_DELAY_SECONDS * 1000;
      
      this.logger.log(`User ${userId} resend check: ${timeDiff}ms since last send, can resend: ${canResend}`);
      return canResend;
    } catch (error) {
      // If table doesn't exist yet, allow sending (graceful fallback)
      if (error.code === '42P01') {
        this.logger.warn('Email verification codes table does not exist yet. Allowing code send.');
        return true;
      }
      throw error;
    }
  }

  async getRemainingDelaySeconds(userId: string): Promise<number> {
    try {
      const latestCode = await this.emailVerificationCodesRepository.findOne({
        where: { userId },
        order: { createdAt: 'DESC' },
      });
      
      if (!latestCode) {
        return 0;
      }

      const timeDiff = Date.now() - latestCode.lastSentAt.getTime();
      const remainingMs = (this.RESEND_DELAY_SECONDS * 1000) - timeDiff;
      
      return remainingMs > 0 ? Math.ceil(remainingMs / 1000) : 0;
    } catch (error) {
      // If table doesn't exist yet, return 0 (no delay)
      if (error.code === '42P01') {
        this.logger.warn('Email verification codes table does not exist yet. Returning 0 delay.');
        return 0;
      }
      throw error;
    }
  }

  async generateAndSendVerificationCode(userId: string): Promise<void> {
    try {
      const user = await this.usersRepository.findOne({ where: { id: userId } });

      if (!user) {
        throw new BadRequestException('User not found');
      }

      if (user.isEmailVerified) {
        throw new BadRequestException('Email is already verified');
      }

      // Check user-based rate limiting (45-second delay between emails to same user)
      await this.checkUserRateLimit(userId);

      this.logger.log(`Generating verification code for user...`);

      // Generate a 6-digit code
      const code = randomInt(100000, 999999).toString();
      const expirationDate = new Date();
      expirationDate.setMinutes(expirationDate.getMinutes() + this.CODE_EXPIRY_MINUTES);


      this.logger.log('deleting existing codes for user...');

      // Delete any existing codes for this user (with error handling for missing table)
      try {
        await this.emailVerificationCodesRepository
          .createQueryBuilder()
          .delete()
          .where('user_id = :userId', { userId: user.id })
          .execute();
      } catch (error) {
        if (error.code === '42P01') {
          this.logger.warn('Email verification codes table does not exist yet. Skipping deletion.');
        } else {
          throw error;
        }
      }

        this.logger.log('Creating new email verification code...');

      // Save the new code (with error handling for missing table)
      try {
        const newCode = this.emailVerificationCodesRepository.create({
          userId: user.id,
          code,
          expiresAt: expirationDate,
          lastSentAt: new Date(),
        });

        this.logger.log(`Saving new verification code for user ${user.id}: ${code}`);

        await this.emailVerificationCodesRepository.save(newCode);
      } catch (error) {
        if (error.code === '42P01') {
          this.logger.warn('Email verification codes table does not exist yet. Cannot save code to database.');
          // Continue with email sending even if we can't save to database
        } else {
          throw error;
        }
      }

      // Send the code via email
      await this.mailService.send({
        to: user.email,
        subject: 'Verify Your GovConnect Email Address',
        template: 'email-verification-code',
        context: {
          name: user.firstName || 'User',
          code,
        },
      });

      this.logger.log(`Email verification code sent to ${user.email}`);
    } catch (error) {
      if (error instanceof ConflictException || error instanceof BadRequestException) {
        throw error; // Re-throw known exceptions
      }
      
      this.logger.error(`Error in generateAndSendVerificationCode: ${error.message}`, error.stack);
      throw new BadRequestException('Failed to send verification email. Please try again.');
    }
  }

  async verifyEmailCode(email: string, code: string): Promise<boolean> {
    try {
      const user = await this.usersRepository.findOne({ where: { email } });
      
      if (!user) {
        return false;
      }

      if (user.isEmailVerified) {
        this.logger.warn(`Attempted to verify already verified email: ${email}`);
        return true; // Email is already verified
      }

      // Find the verification code
      const emailVerificationCode = await this.emailVerificationCodesRepository.findOne({
        where: { userId: user.id, code },
        order: { createdAt: 'DESC' },
      });

      if (!emailVerificationCode) {
        this.logger.warn(`Invalid or expired verification code for user: ${email}`);
        return false;
      }

      // Code is valid, mark email as verified and delete the code
      await this.markEmailAsVerified(user.id);
      await this.emailVerificationCodesRepository.remove(emailVerificationCode);
      
      this.logger.log(`Email verified successfully for user: ${email}`);
      return true;
    } catch (error) {
      this.logger.error(`Error verifying email code: ${error.message}`, error.stack);
      return false;
    }
  }

  async resendVerificationCode(email: string): Promise<void> {
    const user = await this.usersRepository.findOne({ where: { email } });
    
    if (!user) {
      throw new BadRequestException('User not found');
    }

    if (user.isEmailVerified) {
      throw new BadRequestException('Email is already verified');
    }

    await this.generateAndSendVerificationCode(user.id);
  }

  // Cleanup expired codes (can be called by a cron job)
  async cleanupExpiredCodes(): Promise<void> {
    try {
      await this.emailVerificationCodesRepository
        .createQueryBuilder()
        .delete()
        .where('expires_at < :now', { now: new Date() })
        .execute();
      this.logger.log('Expired email verification codes cleaned up');
    } catch (error) {
      this.logger.error(`Error cleaning up expired codes: ${error.message}`, error.stack);
    }
  }
}
