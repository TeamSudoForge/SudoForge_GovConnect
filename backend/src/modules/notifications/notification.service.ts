import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual } from 'typeorm';
import {
  Notification,
  NotificationType,
} from '../../database/entities/notification.entity';
import { MailService } from './mail/mail.service';
import { Cron, CronExpression } from '@nestjs/schedule';
import { FcmService } from './fcm/fcm.service';
import { User } from 'src/database/entities';

@Injectable()
export class NotificationService {
  private readonly templateMap: Record<NotificationType, string> = {
    [NotificationType.GENERAL]: 'basic',
    [NotificationType.APPOINTMENT_CONFIRMATION]: 'appointment-confirmation',
    [NotificationType.APPOINTMENT_REMINDER]: 'appointment-reminder',
    [NotificationType.STATUS_UPDATE]: 'status-update',
    [NotificationType.DOCUMENT_REQUEST]: 'status-update', // Uses same template with different context
    [NotificationType.VERIFICATION]: 'email-verification-code',
    [NotificationType.SYSTEM]: 'basic',
  };

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
    type: NotificationType = NotificationType.GENERAL,
    templateContext: Record<string, any> = {},
  ): Promise<Notification> {
    if (!user || !user.id) {
      throw new Error('Notification must be associated with a valid user');
    }
    const notification = this.notificationRepo.create({
      user,
      title,
      body,
      data,
      scheduledAt,
      type,
      sent: !scheduledAt, // If not scheduled, mark as sent
    });
    const saved = await this.notificationRepo.save(notification);

    // If scheduledAt is in the future, don't send now
    if (scheduledAt && scheduledAt > new Date()) {
      return saved;
    }

    // Get the template based on notification type
    const template = this.templateMap[type] || 'test';

    // Merge the basic context with the template-specific context
    const mergedContext = {
      user,
      title,
      body,
      data,
      name: user.firstName || 'User',
      ...templateContext,
    };

    await this.mailService.send({
      to: user.email,
      subject: title,
      template: template,
      context: mergedContext,
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
    try {
      const now = new Date();
      console.log('Processing scheduled notifications: ' + now.toISOString());
      
      const notifications = await this.notificationRepo.find({
        where: {
          sent: false,
          scheduledAt: LessThanOrEqual(now),
        },
        relations: ['user'],
      });
      
      console.log(`Found ${notifications.length} notifications to process`);
      
      for (const notification of notifications) {
        // Get the template based on notification type
        const template = this.templateMap[notification.type] || 'basic';

        // Create context with user's name
        const context = {
          user: notification.user,
          title: notification.title,
          body: notification.body,
          data: notification.data,
          name: notification.user.firstName || 'User',
        };

        try {
          // If there's data, try to parse it for additional context
          if (notification.data) {
            try {
              const parsedData = JSON.parse(notification.data);
              Object.assign(context, parsedData);
            } catch (e) {
              // If data isn't valid JSON, just use it as is
            }
          }

          await this.mailService.send({
            to: notification.user.email,
            subject: notification.title,
            template: template,
            context: context,
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
        } catch (error) {
          console.error(
            `Failed to process notification ${notification.id}:`,
            error,
          );
        }
      }
    } catch (error) {
      console.error('Error in scheduled notification processing:', error);
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

  /**
   * Create a general notification with an optional action button
   */
  async createGeneralNotification(
    user: User,
    title: string,
    body: string,
    options?: {
      actionUrl?: string;
      actionText?: string;
      details?: Record<string, string>;
      scheduledAt?: Date;
      isJsonData?: boolean;
    },
    data?: string,
  ): Promise<Notification> {
    // Create context for the template
    const templateContext: Record<string, any> = {};

    if (options?.actionUrl) {
      templateContext.actionUrl = options.actionUrl;
      templateContext.actionText = options.actionText || 'View Details';
    }

    if (options?.details) {
      templateContext.details = options.details;
    }

    if (options?.isJsonData) {
      templateContext.isJsonData = true;
    }

    return this.createNotification(
      user,
      title,
      body,
      data,
      options?.scheduledAt,
      NotificationType.GENERAL,
      templateContext,
    );
  }

  /**
   * Create a system notification
   */
  async createSystemNotification(
    user: User,
    title: string,
    body: string,
    options?: {
      actionUrl?: string;
      actionText?: string;
      details?: Record<string, string>;
      scheduledAt?: Date;
    },
    data?: string,
  ): Promise<Notification> {
    // Create context for the template
    const templateContext: Record<string, any> = {};

    if (options?.actionUrl) {
      templateContext.actionUrl = options.actionUrl;
      templateContext.actionText = options.actionText || 'View Details';
    }

    if (options?.details) {
      templateContext.details = options.details;
    }

    return this.createNotification(
      user,
      title,
      body,
      data,
      options?.scheduledAt,
      NotificationType.SYSTEM,
      templateContext,
    );
  }

  /**
   * Create an appointment confirmation notification
   */
  async createAppointmentConfirmation(
    user: User,
    appointmentDetails: {
      serviceName: string;
      departmentName: string;
      appointmentDate: string;
      appointmentTime: string;
      location: string;
      referenceNumber: string;
      qrCodeUrl?: string;
      mapUrl?: string;
    },
    scheduledAt?: Date,
  ): Promise<Notification> {
    return this.createNotification(
      user,
      'Appointment Confirmation',
      `Your appointment for ${appointmentDetails.serviceName} has been confirmed.`,
      JSON.stringify(appointmentDetails),
      scheduledAt,
      NotificationType.APPOINTMENT_CONFIRMATION,
      appointmentDetails,
    );
  }

  /**
   * Create an appointment reminder notification with document checklist
   */
  async createAppointmentReminder(
    user: User,
    appointmentDetails: {
      serviceName: string;
      departmentName: string;
      appointmentDate: string;
      appointmentTime: string;
      location: string;
      referenceNumber: string;
      requiredDocuments: string[];
      qrCodeUrl?: string;
    },
    scheduledAt?: Date,
  ): Promise<Notification> {
    return this.createNotification(
      user,
      'Appointment Reminder',
      `Your appointment for ${appointmentDetails.serviceName} is tomorrow.`,
      JSON.stringify(appointmentDetails),
      scheduledAt,
      NotificationType.APPOINTMENT_REMINDER,
      appointmentDetails,
    );
  }

  /**
   * Create a status update notification
   */
  async createStatusUpdate(
    user: User,
    updateDetails: {
      status: string;
      statusClass: string;
      serviceName: string;
      departmentName: string;
      referenceNumber: string;
      updateDate: string;
      officerName: string;
      message: string;
      additionalDocumentsRequired?: boolean;
      additionalDocuments?: string[];
      deadline?: string;
      portalUrl?: string;
      nextAppointmentRequired?: boolean;
      appointmentUrl?: string;
      isCompleted?: boolean;
      downloadUrl?: string;
    },
    scheduledAt?: Date,
  ): Promise<Notification> {
    return this.createNotification(
      user,
      `${updateDetails.serviceName}: ${updateDetails.status}`,
      updateDetails.message,
      JSON.stringify(updateDetails),
      scheduledAt,
      NotificationType.STATUS_UPDATE,
      updateDetails,
    );
  }

  /**
   * Create a document request notification
   */
  async createDocumentRequest(
    user: User,
    requestDetails: {
      serviceName: string;
      departmentName: string;
      referenceNumber: string;
      updateDate: string;
      officerName: string;
      message: string;
      additionalDocuments: string[];
      deadline: string;
      portalUrl: string;
    },
    scheduledAt?: Date,
  ): Promise<Notification> {
    // Customize for document request
    const updateDetails = {
      status: 'Documents Requested',
      statusClass: 'status-action-required',
      additionalDocumentsRequired: true,
      ...requestDetails,
    };

    return this.createNotification(
      user,
      `${requestDetails.serviceName}: Documents Required`,
      requestDetails.message,
      JSON.stringify(updateDetails),
      scheduledAt,
      NotificationType.DOCUMENT_REQUEST,
      updateDetails,
    );
  }
}
