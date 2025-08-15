import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { FormsModule } from './modules/forms/forms.module';
import { HealthModule } from './health/health.module';
import { RelyingPartyModule } from './relying-party/relying-party.module';
import configuration from './config/configuration';
import { User } from './database/entities/user.entity';
import { AuthSession } from './database/entities/auth-session.entity';
import { Passkey } from './database/entities/passkey.entity';
import { TwoFactorCode } from './modules/auth/two-factor/entities/two-factor-code.entity';
import { EmailVerificationCode } from './database/entities';
import { 
  FieldType, 
  Field, 
  FieldAttribute, 
  Department, 
  Service, 
  FormField, 
  FormResponse, 
  FormResponseValue 
} from './modules/forms/entities';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get('DB_PORT', 5432),
        username: configService.get('DB_USERNAME', 'postgres'),
        password: configService.get('DB_PASSWORD', 'password'),
        database: configService.get('DB_NAME', 'govconnect'),
        entities: [
          User,
          AuthSession,
          Passkey,
          TwoFactorCode,
          EmailVerificationCode,
          FieldType,
          Field,
          FieldAttribute,
          Department,
          Service,
          FormField,
          FormResponse,
          FormResponseValue
        ],
        synchronize: configService.get('DB_SYNCHRONIZE', 'false') === 'true',
        logging: configService.get('DB_LOGGING', 'false') === 'true',
      }),
    }),
    DatabaseModule,
    AuthModule,
    UsersModule,
    FormsModule,
    HealthModule,
    RelyingPartyModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
