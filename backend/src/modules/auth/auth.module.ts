import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { User } from '../../database/entities/user.entity';
import { UsersModule } from '../users/users.module';
import { AuthSession } from '../../database/entities/auth-session.entity';
import { Passkey } from '../../database/entities/passkey.entity';
import { AuthSessionRepository } from './repositories/auth-session.repository';
import { PasskeyRepository } from './repositories/passkey.repository';
import { UserRepository } from './repositories/user.repository';
import { TwoFactorService } from './two-factor/two-factor.service';
import { TwoFactorCode } from './two-factor/entities/two-factor-code.entity';
import { TwoFactorModule } from './two-factor/two-factor.module';
import { EmailVerificationModule } from './email-verification/email-verification.module';
import { EmailVerificationCode } from './email-verification/entities/email-verification-code.entity';
import { MailService } from '../notifications/mail/mail.service';
import { EmailVerificationService } from './email-verification/email-verification.service';
import { JwtStrategy } from 'src/common/strategies/jwt.strategy';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, AuthSession, Passkey, TwoFactorCode, EmailVerificationCode]),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: { 
          expiresIn: configService.get<string>('JWT_EXPIRES_IN', '15m') 
        },
      }),
    }),
    PassportModule.register({ defaultStrategy: 'jwt' }),
    UsersModule,
    ConfigModule,
    TwoFactorModule,
    EmailVerificationModule,
  ],
  controllers: [AuthController],
  providers: [
    AuthService, 
    JwtStrategy, 
    AuthSessionRepository, 
    PasskeyRepository, 
    UserRepository, 
    TwoFactorService,
    EmailVerificationService,
    MailService
  ],
  exports: [
    AuthService, 
    JwtStrategy, 
    PassportModule,
    AuthSessionRepository, 
    PasskeyRepository, 
    UserRepository, 
    TwoFactorService,
    EmailVerificationService
  ],
})
export class AuthModule {}
