import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './notification.entity';
import { User } from '../users/entities/user.entity';
@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
  ) {}

  async createNotification(
    user: User,
    title: string,
    body: string,
    data?: string,
  ): Promise<Notification> {
    const notification = this.notificationRepo.create({
      user,
      title,
      body,
      data,
    });
    return this.notificationRepo.save(notification);
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
