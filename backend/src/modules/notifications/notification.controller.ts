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
import { User } from 'src/modules/users/entities/user.entity';

interface RequestWithUser extends Request {
  user: User;
}

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Get()
  async getUserNotifications(@Request() req: RequestWithUser) {
    if (req.user) {
      const userId = req.user.id;
      return this.notificationService.getUserNotifications(userId);
    }
  }

  @Post('mark-read/:id')
  async markAsRead(@Param('id') id: string) {
    await this.notificationService.markAsRead(id);
    return { success: true };
  }

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
}
