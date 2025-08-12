import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { randomInt } from 'crypto';
import { TwoFactorCode } from './entities/two-factor-code.entity';
import { MailService } from 'src/modules/notifications/mail/mail.service';

@Injectable()
export class TwoFactorService {
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
    const user = await this.usersRepository.findOne({ where: { email } });

    if (!user || !user.isTwoFactorEnabled) {
      return;
    }

    // Generate a 6-digit code
    const code = randomInt(100000, 999999).toString();
    const expirationDate = new Date();
    expirationDate.setMinutes(expirationDate.getMinutes() + 10); //valid for 10 minutes

    // Save the code
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
        name: user.firstName,
        code,
      },
    });
  }

  async verifyCode(email: string, code: string): Promise<boolean> {
    const user = await this.usersRepository.findOne({ where: { email } });
    
    if (!user) {
      return false;
    }

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
  }
}
