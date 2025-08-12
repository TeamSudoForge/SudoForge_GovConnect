import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  generateRegistrationOptions,
  generateAuthenticationOptions,
  verifyRegistrationResponse,
  verifyAuthenticationResponse,
} from '@simplewebauthn/server';
import {
  RegistrationResponseJSON,
  AuthenticationResponseJSON,
} from '@simplewebauthn/browser';
import { v4 as uuidv4 } from 'uuid';
import { UsersService } from '../users/users.service';
import { User, AuthSession, Passkey } from '../../database/entities';
import {
  RegisterDto,
  LoginDto,
  AuthResponseDto,
  PasskeyRegistrationDto,
  PasskeyOptionsDto,
  RefreshTokenDto,
} from './dto/auth.dto';
import { JwtPayload } from '../../common/strategies/jwt.strategy';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private configService: ConfigService,
    @InjectRepository(AuthSession)
    private authSessionRepository: Repository<AuthSession>,
    @InjectRepository(Passkey)
    private passkeyRepository: Repository<Passkey>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const user = await this.usersService.create(registerDto);
    return this.generateTokens(user);
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const user = await this.validateUser(loginDto.email, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('INVALID_CREDENTIALS');
    }
    return this.generateTokens(user);
  }

  async loginWithUser(user: User): Promise<AuthResponseDto> {
    return this.generateTokens(user);
  }

  async validateUser(email: string, password: string): Promise<User | null> {
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      return null;
    }

    const isPasswordValid = await this.usersService.validatePassword(password, user.passwordHash);
    if (!isPasswordValid) {
      return null;
    }

    return user;
  }

  async refreshToken(refreshTokenDto: RefreshTokenDto): Promise<AuthResponseDto> {
    const session = await this.authSessionRepository.findOne({
      where: { refreshToken: refreshTokenDto.refreshToken },
      relations: ['user'],
    });

    if (!session || session.expiresAt < new Date()) {
      throw new UnauthorizedException('INVALID_REFRESH_TOKEN');
    }

    // Delete old session
    await this.authSessionRepository.remove(session);

    // Generate new tokens
    return this.generateTokens(session.user);
  }

  private async generateTokens(user: User): Promise<AuthResponseDto> {
    const payload: JwtPayload = {
      sub: user.id,
      username: user.username,
      email: user.email,
    };

    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('jwt.expiresIn'),
    });

    const refreshToken = uuidv4();
    const refreshTokenExpiresIn = this.configService.get('jwt.refreshTokenExpiresIn') || '7d';
    
    // Calculate expiration date
    const expiresAt = new Date();
    if (refreshTokenExpiresIn.includes('d')) {
      const days = parseInt(refreshTokenExpiresIn.replace('d', ''));
      expiresAt.setDate(expiresAt.getDate() + days);
    } else if (refreshTokenExpiresIn.includes('h')) {
      const hours = parseInt(refreshTokenExpiresIn.replace('h', ''));
      expiresAt.setHours(expiresAt.getHours() + hours);
    }

    // Save refresh token
    await this.authSessionRepository.save({
      userId: user.id,
      refreshToken,
      expiresAt,
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
      },
      accessToken,
      refreshToken,
    };
  }

  // Passkey methods - Simplified implementation
  async generatePasskeyRegistrationOptions(userId: string, displayName: string): Promise<any> {
    const user = await this.usersService.findById(userId);
    
    // Basic passkey registration options
    const options = {
      challenge: Buffer.from(uuidv4()).toString('base64url'),
      rp: {
        name: this.configService.get('auth.rpName') || 'GovConnect',
        id: this.configService.get('auth.rpID') || 'localhost',
      },
      user: {
        id: Buffer.from(user.id).toString('base64url'),
        name: user.email,
        displayName,
      },
      pubKeyCredParams: [
        { alg: -7, type: 'public-key' },
        { alg: -257, type: 'public-key' },
      ],
      authenticatorSelection: {
        authenticatorAttachment: 'platform',
        userVerification: 'preferred',
        requireResidentKey: false,
      },
      timeout: 60000,
      attestation: 'none',
    };

    return options;
  }

  async verifyPasskeyRegistration(
    userId: string,
    displayName: string,
    credential: any,
  ): Promise<void> {
    const user = await this.usersService.findById(userId);

    // For now, we'll store the passkey without full WebAuthn verification
    await this.passkeyRepository.save({
      userId: user.id,
      credentialId: credential.id,
      credentialPublicKey: credential.response.publicKey || JSON.stringify(credential.response),
      credentialCounter: 0,
      displayName,
      credentialBackedUp: false,
      transports: credential.response.transports || [],
    });
  }

  async generatePasskeyAuthenticationOptions(): Promise<any> {
    return {
      challenge: Buffer.from(uuidv4()).toString('base64url'),
      timeout: 60000,
      userVerification: 'preferred',
      rpId: this.configService.get('auth.rpID') || 'localhost',
    };
  }

  async verifyPasskeyAuthentication(credential: any): Promise<AuthResponseDto> {
    const passkey = await this.passkeyRepository.findOne({
      where: { credentialId: credential.id },
      relations: ['user'],
    });

    if (!passkey) {
      throw new UnauthorizedException('PASSKEY_NOT_FOUND');
    }

    // For demo purposes, we'll trust the passkey if it exists
    return this.generateTokens(passkey.user);
  }

  async getUserPasskeys(userId: string): Promise<Passkey[]> {
    return this.passkeyRepository.find({
      where: { userId },
      select: ['id', 'displayName', 'createdAt'],
    });
  }

  async deletePasskey(userId: string, passkeyId: string): Promise<void> {
    const result = await this.passkeyRepository.delete({
      id: passkeyId,
      userId,
    });

    if (result.affected === 0) {
      throw new BadRequestException('PASSKEY_NOT_FOUND');
    }
  }

  async findByEmail(email: string): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }
    return user;
  }
}
