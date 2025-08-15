import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { ConfigService } from '@nestjs/config';
import { User } from '../../database/entities';
import { RegisterDto } from '../auth/dto/auth.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private configService: ConfigService,
  ) {}

  async create(registerDto: RegisterDto & { isEmailVerified?: boolean }): Promise<User> {
    const { email, password, firstName, lastName, username, isEmailVerified = true } = registerDto;

    // Check if user already exists
    const existingUser = await this.userRepository.findOne({
      where: [{ email }, { username }],
    });

    if (existingUser) {
      if (existingUser.email === email) {
        throw new ConflictException('EMAIL_ALREADY_EXISTS');
      }
      if (existingUser.username === username) {
        throw new ConflictException('USERNAME_ALREADY_EXISTS');
      }
    }

    // Hash password
    const bcryptRounds = this.configService.get('auth.bcryptRounds') || 12;
    const passwordHash = await bcrypt.hash(password, bcryptRounds);

    // Create user
    const user = this.userRepository.create({
      email,
      username,
      passwordHash,
      firstName,
      lastName,
      isEmailVerified,
    });

    return this.userRepository.save(user);
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  async findByUsername(username: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { username } });
  }

  async findById(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('USER_NOT_FOUND');
    }
    return user;
  }

  async validatePassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }
}
