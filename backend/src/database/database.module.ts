import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { User, AuthSession, Passkey, TwoFactorCode, EmailVerificationCode } from './entities';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('database.host'),
        port: configService.get('database.port'),
        username: configService.get('database.username'),
        password: configService.get('database.password'),
        database: configService.get('database.database'),
        entities: [User, AuthSession, Passkey, TwoFactorCode, EmailVerificationCode],
        synchronize: configService.get('database.synchronize'),
        logging: configService.get('database.logging'),
      }),
      inject: [ConfigService],
    }),
  ],
})
export class DatabaseModule {}
