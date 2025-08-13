import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { AuthSession } from '../../../database/entities/auth-session.entity';

@Injectable()
export class AuthSessionRepository {
  constructor(
    @InjectRepository(AuthSession)
    private repository: Repository<AuthSession>,
  ) {}

  async create(data: Partial<AuthSession>): Promise<AuthSession> {
    const authSession = this.repository.create(data);
    return this.repository.save(authSession);
  }

  async findByUserId(userId: string): Promise<AuthSession[]> {
    return this.repository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async findByToken(refreshToken: string): Promise<AuthSession | null> {
    return this.repository.findOne({
      where: { refreshToken },
      relations: ['user'],
    });
  }

  async findActiveByToken(refreshToken: string): Promise<AuthSession | null> {
    return this.repository.findOne({
      where: {
        refreshToken,
        expiresAt: MoreThan(new Date()),
      },
      relations: ['user'],
    });
  }

  async deleteByToken(refreshToken: string): Promise<void> {
    await this.repository.delete({ refreshToken });
  }

  async deleteAllForUser(userId: string): Promise<void> {
    await this.repository.delete({ userId });
  }

  async deleteExpiredSessions(): Promise<void> {
    await this.repository
      .createQueryBuilder()
      .delete()
      .where('expires_at < :now', { now: new Date() })
      .execute();
  }
}
