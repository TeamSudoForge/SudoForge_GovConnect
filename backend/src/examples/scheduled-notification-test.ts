// scheduled-notification-test.ts
// Test script to create a notification scheduled 4 minutes in the future

import { NotificationService } from '../modules/notifications/notification.service';
import { AuthService } from '../modules/auth/auth.service';
import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';

async function bootstrap() {
  // Create a NestJS application context to access services
  const app = await NestFactory.createApplicationContext(AppModule);

  try {
    console.log('Starting scheduled notification test...');

    // Get services
    const authService = app.get(AuthService);
    const notificationService = app.get(NotificationService);

    // Get a test user by email
    const testEmail = 'demo@example.com'; // Replace with a valid user email
    const user = await authService.findByEmail(testEmail);

    if (!user) {
      console.error(`User with email ${testEmail} not found.`);
      await app.close();
      process.exit(1);
    }

    console.log(
      `Found user: ${user.firstName} ${user.lastName} (${user.email})`,
    );

    // Schedule time - 4 minutes from now
    const scheduledAt = new Date(Date.now() + 4 * 60 * 1000);
    console.log(`Scheduling notification for: ${scheduledAt.toLocaleString()}`);

    // Create three different types of notifications to test different templates

    // 1. Create a general notification
    const generalNotification =
      await notificationService.createGeneralNotification(
        user,
        'Scheduled General Notification',
        'This notification was scheduled to be sent 4 minutes after the script ran.',
        {
          actionUrl: 'https://example.com',
          actionText: 'Visit Example',
          details: {
            'Scheduled at': scheduledAt.toLocaleString(),
            'Current time': new Date().toLocaleString(),
          },
          scheduledAt: scheduledAt,
        },
      );
    console.log(
      `Created general notification with ID: ${generalNotification.id}`,
    );

    // 2. Create an appointment confirmation notification
    const appointmentNotification =
      await notificationService.createAppointmentConfirmation(
        user,
        {
          serviceName: 'Passport Renewal',
          departmentName: 'Department of Immigration and Emigration',
          appointmentDate: 'September 15, 2023',
          appointmentTime: '10:30 AM - 11:00 AM',
          location: 'Battaramulla Office',
          referenceNumber: 'APT-2023-09-123456',
          qrCodeUrl:
            'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=APT-2023-09-123456',
          mapUrl:
            'https://maps.google.com/?q=Department+of+Immigration,Battaramulla',
        },
        new Date(Date.now() + 4 * 60 * 1000 + 10000), // 10 seconds after the general notification
      );
    console.log(
      `Created appointment notification with ID: ${appointmentNotification.id}`,
    );

    // 3. Create a status update notification
    const statusUpdateNotification =
      await notificationService.createStatusUpdate(
        user,
        {
          status: 'In Progress',
          statusClass: 'status-in-progress',
          serviceName: 'Passport Renewal',
          departmentName: 'Department of Immigration and Emigration',
          referenceNumber: 'REF-2023-09-123456',
          updateDate: new Date().toLocaleDateString(),
          officerName: 'John Doe',
          message:
            'Your application is currently being processed. We will notify you when it is ready.',
          portalUrl: 'https://example.com/track/REF-2023-09-123456',
        },
        new Date(Date.now() + 4 * 60 * 1000 + 20000), // 20 seconds after the general notification
      );
    console.log(
      `Created status update notification with ID: ${statusUpdateNotification.id}`,
    );

    console.log('\nAll notifications have been scheduled successfully!');
    console.log(
      `Check your email (${user.email}) in about 4 minutes to see the notifications.`,
    );
    console.log(
      'The notifications should also appear in the app if you have a valid FCM token registered.',
    );
  } catch (error) {
    console.error('Error scheduling notifications:', error);
  } finally {
    await app.close();
  }
}

// Run the script
bootstrap()
  .then(() => {
    console.log('Test complete!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
