import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { NotificationService } from './notification.service';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth.guard';
import { User } from 'src/database/entities';

interface RequestWithUser extends Request {
  user: User;
}

@Controller('notifications')
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  async getUserNotifications(@Request() req: RequestWithUser) {
    if (req.user) {
      const userId = req.user.id;
      return this.notificationService.getUserNotifications(userId);
    }
  }

  @UseGuards(JwtAuthGuard)
  @Post('mark-read/:id')
  async markAsRead(@Param('id') id: string) {
    await this.notificationService.markAsRead(id);
    return { success: true };
  }

  @UseGuards(JwtAuthGuard)
  @Post('register-token')
  async registerFcmToken(
    @Body('token') token: string,
    @Request() req: RequestWithUser,
  ) {
    if (req.user) {
      const userId = req.user.id;
      await this.notificationService.saveFcmToken(userId, token);
      return { success: true, message: 'FCM token registered successfully' };
    }
    return { success: false, message: 'User not authenticated' };
  }

  @Post('test')
  async testNotification(
    @Request() req: RequestWithUser,
    @Body() body: { email?: string; fcmToken?: string; scheduledAt?: string },
  ) {
    // Use authenticated user if available, else fallback to provided email/fcmToken
    let user: User | undefined = req.user;
    if (!user && (body.email || body.fcmToken)) {
      user = new User();
      user.email = body.email || 'test@example.com';
      user.fcmToken = body.fcmToken ?? null;
    }
    if (!user) {
      return { success: false, message: 'No user or test data provided' };
    }
    const scheduledAt = body.scheduledAt
      ? new Date(body.scheduledAt)
      : undefined;
    await this.notificationService.createNotification(
      user,
      'Test Notification',
      'This is a test notification for both email and FCM.',
      JSON.stringify({ test: 'value' }),
      scheduledAt,
    );
    return { success: true, message: 'Test notification triggered' };
  }
}
