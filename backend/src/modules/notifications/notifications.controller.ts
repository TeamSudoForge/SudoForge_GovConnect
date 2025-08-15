import { Controller, Post, Body, Logger } from '@nestjs/common';

@Controller('fcm')
export class NotificationsController {
  private readonly logger = new Logger(NotificationsController.name);

  @Post('token')
  async receiveFcmToken(@Body('token') token: string) {
    this.logger.log(`Received FCM token: ${token}`);

    return { success: true };
  }
}
