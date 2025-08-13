import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Passkey } from '../../../database/entities/passkey.entity';

@Injectable()
export class PasskeyRepository {
  constructor(
    @InjectRepository(Passkey)
    private repository: Repository<Passkey>,
  ) {}

  async create(data: Partial<Passkey>): Promise<Passkey> {
    const passkey = this.repository.create(data);
    return this.repository.save(passkey);
  }

  async findByCredentialId(credentialId: string): Promise<Passkey | null> {
    return this.repository.findOne({
      where: { credentialId },
      relations: ['user'],
    });
  }

  async findByUserId(userId: string): Promise<Passkey[]> {
    return this.repository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async update(id: string, data: Partial<Passkey>): Promise<void> {
    await this.repository.update(id, data);
  }

  async delete(id: string): Promise<void> {
    await this.repository.delete(id);
  }

  async deleteAllForUser(userId: string): Promise<void> {
    await this.repository.delete({ userId });
  }

  async findById(id: string): Promise<Passkey | null> {
    return this.repository.findOne({
      where: { id },
    });
  }

  async findByIdAndUserId(id: string, userId: string): Promise<Passkey | null> {
    return this.repository.findOne({
      where: { id, userId },
    });
  }
}
