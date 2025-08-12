import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { User } from '../users/entities/user.entity';
import { UsersModule } from '../users/users.module';
import { TwoFactorService } from './two-factor/two-factor.service';
import { TwoFactorCode } from './two-factor/entities/two-factor-code.entity';
import { MailService } from '../notifications/mail/mail.service';
import { JwtStrategy } from 'src/common/strategies/jwt.strategy';

@Module({
  imports: [
    PassportModule,
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
    TypeOrmModule.forFeature([User, TwoFactorCode]),
    UsersModule,
    ConfigModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, TwoFactorService, MailService],
  exports: [AuthService, TwoFactorService],
})
export class AuthModule {}
