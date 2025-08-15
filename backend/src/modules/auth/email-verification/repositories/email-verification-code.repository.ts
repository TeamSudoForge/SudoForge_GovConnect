import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { EmailVerificationCode } from '../entities/email-verification-code.entity';

@Injectable()
export class EmailVerificationCodeRepository {
  constructor(
    @InjectRepository(EmailVerificationCode)
    private repository: Repository<EmailVerificationCode>,
  ) {}

  async create(data: Partial<EmailVerificationCode>): Promise<EmailVerificationCode> {
    const emailVerificationCode = this.repository.create(data);
    return this.repository.save(emailVerificationCode);
  }

  async findValidCode(userId: string, code: string): Promise<EmailVerificationCode | null> {
    return this.repository.findOne({
      where: {
        userId,
        code,
        expiresAt: MoreThan(new Date()),
      },
      order: { createdAt: 'DESC' },
    });
  }

  async findLatestCodeForUser(userId: string): Promise<EmailVerificationCode | null> {
    return this.repository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async remove(code: EmailVerificationCode): Promise<void> {
    await this.repository.remove(code);
  }

  async deleteExpiredCodes(): Promise<void> {
    await this.repository
      .createQueryBuilder()
      .delete()
      .where('expires_at < :now', { now: new Date() })
      .execute();
  }

  async deleteUserCodes(userId: string): Promise<void> {
    await this.repository
      .createQueryBuilder()
      .delete()
      .where('user_id = :userId', { userId })
      .execute();
  }
}
