import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TwoFactorService } from './two-factor.service';
import { TwoFactorCode } from './entities/two-factor-code.entity';
import { User } from '../../../database/entities/user.entity';
import { MailModule } from '../../notifications/mail/mail.module';
import { TwoFactorCodeRepository } from './repositories/two-factor-code.repository';
import { UserRepository } from '../repositories/user.repository';

@Module({
  imports: [
    TypeOrmModule.forFeature([TwoFactorCode, User]),
    MailModule,
  ],
  providers: [
    TwoFactorService,
    TwoFactorCodeRepository,
    UserRepository,
  ],
  exports: [TwoFactorService],
})
export class TwoFactorModule {}
