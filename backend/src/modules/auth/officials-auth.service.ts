import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Official } from '../forms/entities/official.entity';
import {
  OfficialLoginDto,
  OfficialRegisterDto,
  OfficialAuthResponseDto,
} from './dto/officials-auth.dto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class OfficialsAuthService {
  private readonly logger = new Logger(OfficialsAuthService.name);

  constructor(
    @InjectRepository(Official)
    private officialsRepository: Repository<Official>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: OfficialRegisterDto): Promise<OfficialAuthResponseDto> {
    const { name, email, password, designation, department, division, contact_phone } = registerDto;

    // Check if official already exists
    const existingOfficial = await this.officialsRepository.findOne({
      where: { email },
    });

    if (existingOfficial) {
      throw new BadRequestException('Official with this email already exists');
    }

    // Create new official
    const official = this.officialsRepository.create({
      name,
      email,
      password_hash: password, // Will be hashed by entity @BeforeInsert hook
      designation,
      department,
      division,
      contact_phone,
    });

    try {
      const savedOfficial = await this.officialsRepository.save(official);
      this.logger.log(`New official registered: ${savedOfficial.email}`);

      // Generate tokens
      const tokens = await this.generateTokens(savedOfficial);

      return {
        official: this.sanitizeOfficial(savedOfficial),
        ...tokens,
      };
    } catch (error) {
      this.logger.error(`Registration failed: ${error.message}`);
      throw new BadRequestException('Registration failed');
    }
  }

  async login(loginDto: OfficialLoginDto): Promise<OfficialAuthResponseDto> {
    const { email, password } = loginDto;

    // Find official by email
    const official = await this.officialsRepository.findOne({
      where: { email },
    });

    if (!official) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check if official is active
    if (!official.isActive) {
      throw new UnauthorizedException('Account is deactivated');
    }

    // Validate password
    const isPasswordValid = await official.validatePassword(password);

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    this.logger.log(`Official logged in: ${official.email}`);

    // Generate tokens
    const tokens = await this.generateTokens(official);

    return {
      official: this.sanitizeOfficial(official),
      ...tokens,
    };
  }

  async validateOfficial(officialId: number): Promise<Official> {
    const official = await this.officialsRepository.findOne({
      where: { official_id: officialId },
    });

    if (!official || !official.isActive) {
      throw new UnauthorizedException('Official not found or inactive');
    }

    return official;
  }

  private async generateTokens(official: Official) {
    const payload = {
      sub: official.official_id,
      email: official.email,
      type: 'official',
      role: official.role,
    };

    const accessToken = await this.jwtService.signAsync(payload);
    const refreshToken = await this.jwtService.signAsync(payload, {
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: 900, // 15 minutes in seconds
    };
  }

  private sanitizeOfficial(official: Official) {
    const { password_hash, ...sanitized } = official;
    return sanitized;
  }
}