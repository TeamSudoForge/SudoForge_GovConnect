import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmailVerificationService } from './email-verification.service';
import { EmailVerificationCode } from './entities/email-verification-code.entity';
import { User } from '../../../database/entities/user.entity';
import { MailModule } from '../../notifications/mail/mail.module';
import { EmailVerificationCodeRepository } from './repositories/email-verification-code.repository';

@Module({
  imports: [
    TypeOrmModule.forFeature([EmailVerificationCode, User]),
    MailModule,
  ],
  providers: [
    EmailVerificationService,
    EmailVerificationCodeRepository,
  ],
  exports: [EmailVerificationService],
})
export class EmailVerificationModule {}
