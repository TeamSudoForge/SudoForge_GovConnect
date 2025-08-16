import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual } from 'typeorm';
import { Notification } from './notification.entity';
import { MailService } from './mail/mail.service';
import { Cron, CronExpression } from '@nestjs/schedule';
import { FcmService } from './fcm/fcm.service';
import { User } from 'src/database/entities';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
    private readonly mailService: MailService,
    private readonly fcmService: FcmService,
  ) {}

  async createNotification(
    user: User,
    title: string,
    body: string,
    data?: string,
    scheduledAt?: Date,
  ): Promise<Notification> {
    const notification = this.notificationRepo.create({
      user,
      title,
      body,
      data,
      scheduledAt,
      sent: !scheduledAt, // If not scheduled, mark as sent
    });
    const saved = await this.notificationRepo.save(notification);

    // If scheduledAt is in the future, don't send now
    if (scheduledAt && scheduledAt > new Date()) {
      return saved;
    }

    await this.mailService.send({
      to: user.email,
      subject: title,
      template: 'basic',
      context: { user, title, body, data },
    });

    if (user.fcmToken) {
      await this.sendFcmNotification(user.fcmToken, title, body, data);
    }

    await this.notificationRepo.update(saved.id, { sent: true });
    return saved;
  }

  async sendFcmNotification(
    token: string,
    title: string,
    body: string,
    data?: string,
  ) {
    let parsedData: Record<string, any> | undefined = undefined;
    if (data) {
      try {
        parsedData = JSON.parse(data) as Record<string, any>;
      } catch {
        parsedData = undefined;
      }
    }
    await this.fcmService.sendNotification({
      token,
      title,
      body,
      data: parsedData,
    });
  }

  @Cron(CronExpression.EVERY_MINUTE)
  async processScheduledNotifications() {
    const now = new Date();
    const notifications = await this.notificationRepo.find({
      where: {
        sent: false,
        scheduledAt: LessThanOrEqual(now),
      },
      relations: ['user'],
    });
    for (const notification of notifications) {
      await this.mailService.send({
        to: notification.user.email,
        subject: notification.title,
        template: 'basic',
        context: {
          user: notification.user,
          title: notification.title,
          body: notification.body,
          data: notification.data,
        },
      });
      if (notification.user.fcmToken) {
        await this.sendFcmNotification(
          notification.user.fcmToken,
          notification.title,
          notification.body,
          notification.data,
        );
      }
      await this.notificationRepo.update(notification.id, { sent: true });
    }
  }

  async getUserNotifications(userId: string): Promise<Notification[]> {
    return this.notificationRepo.find({
      where: { user: { id: userId } },
      order: { createdAt: 'DESC' },
    });
  }

  async markAsRead(notificationId: string): Promise<void> {
    await this.notificationRepo.update(notificationId, { read: true });
  }

  async saveFcmToken(userId: string, token: string): Promise<void> {
    const user = await this.notificationRepo.manager.findOne(User, {
      where: { id: userId },
    });
    if (user) {
      user.fcmToken = token;
      await this.notificationRepo.manager.save(user);
    } else {
      throw new Error('User not found');
    }
  }
}
