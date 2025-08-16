import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Notification } from '../../database/entities/notification.entity';
import { NotificationService } from './notification.service';
import { NotificationController } from './notification.controller';
import { MailModule } from './mail/mail.module';
import { FcmService } from './fcm/fcm.service';

@Module({
  imports: [TypeOrmModule.forFeature([Notification]), MailModule],
  providers: [NotificationService, FcmService],
  controllers: [NotificationController],
  exports: [NotificationService],
})
export class NotificationModule {}
