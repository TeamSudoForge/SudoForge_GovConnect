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
import { AuthService } from '../auth/auth.service';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth.guard';
import { User } from 'src/database/entities';

interface RequestWithUser extends Request {
  user: User;
}

@Controller('notifications')
export class NotificationController {
  constructor(
    private readonly notificationService: NotificationService,
    private readonly authService: AuthService,
  ) {}

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
    let user: User | undefined = req.user;
    if (body.email) {
      user = await this.authService.findByEmail(body.email);
    }
    if (!user) {
      return { success: false, message: 'User not found' };
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
