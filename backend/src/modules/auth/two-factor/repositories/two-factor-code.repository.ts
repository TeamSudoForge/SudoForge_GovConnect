import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { TwoFactorCode } from '../entities/two-factor-code.entity';

@Injectable()
export class TwoFactorCodeRepository {
  constructor(
    @InjectRepository(TwoFactorCode)
    private repository: Repository<TwoFactorCode>,
  ) {}

  async create(data: Partial<TwoFactorCode>): Promise<TwoFactorCode> {
    const twoFactorCode = this.repository.create(data);
    return this.repository.save(twoFactorCode);
  }

  async findValidCode(userId: string, code: string): Promise<TwoFactorCode | null> {
    return this.repository.findOne({
      where: {
        userId,
        code,
        expiresAt: MoreThan(new Date()),
      },
      order: { createdAt: 'DESC' },
    });
  }

  async remove(code: TwoFactorCode): Promise<void> {
    await this.repository.remove(code);
  }

  async deleteExpiredCodes(): Promise<void> {
    await this.repository
      .createQueryBuilder()
      .delete()
      .where('expires_at < :now', { now: new Date() })
      .execute();
  }
}
