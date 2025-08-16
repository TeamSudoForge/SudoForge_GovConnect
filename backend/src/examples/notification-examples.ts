// Example usage of the NotificationService with different notification types

import { NotificationService } from '../modules/notifications/notification.service';
import { User } from '../database/entities/user.entity';
import { NotificationType } from '../database/entities/notification.entity';

/**
 * This file shows examples of how to use the NotificationService
 * with different types of notifications.
 *
 * Not meant for production use - just for demonstration.
 */

// Example function to demonstrate notification usage
export async function sendExampleNotifications(
  notificationService: NotificationService,
  user: User,
) {
  // 1. Basic general notification
  await notificationService.createNotification(
    user,
    'Welcome to GovConnect',
    'Thank you for registering with GovConnect, your gateway to government services.',
    JSON.stringify({ action: 'welcome' }),
    undefined, // not scheduled
    NotificationType.GENERAL,
  );

  // 1.1 Enhanced general notification with action button
  await notificationService.createGeneralNotification(
    user,
    'Complete Your Profile',
    'Please take a moment to complete your profile information to get the most out of GovConnect services.',
    {
      actionUrl: 'https://govconnect.example.com/profile',
      actionText: 'Update Profile',
      details: {
        'Account Type': 'Citizen',
        Status: 'Incomplete',
        'Missing Items': 'Address, Phone, ID Verification',
      },
    },
  );

  // 1.2 System notification with action button
  await notificationService.createSystemNotification(
    user,
    'System Maintenance',
    'GovConnect will be undergoing scheduled maintenance this weekend. Some services may be temporarily unavailable.',
    {
      details: {
        'Start Time': 'Saturday, August 19, 2023 at 11:00 PM',
        'End Time': 'Sunday, August 20, 2023 at 3:00 AM',
        'Affected Services': 'Document Upload, Appointment Booking',
      },
      actionUrl: 'https://govconnect.example.com/system-status',
      actionText: 'View System Status',
    },
  );

  // 2. Appointment confirmation
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const formattedDate = tomorrow.toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  await notificationService.createAppointmentConfirmation(user, {
    serviceName: 'Driver License Renewal',
    departmentName: 'Department of Transportation',
    appointmentDate: formattedDate,
    appointmentTime: '10:30 AM',
    location: '123 Government Center, Floor 2, Room 245',
    referenceNumber: 'APT-12345',
    qrCodeUrl: 'https://example.com/qr/12345',
    mapUrl: 'https://maps.example.com/location/govt-center',
  });

  // 3. Appointment reminder with required documents
  // Schedule this for 24 hours before appointment
  //   const reminderTime = new Date(tomorrow);
  //   reminderTime.setDate(reminderTime.getDate() - 1); // 24 hours before appointment

  const reminderTime = new Date(tomorrow);
  reminderTime.setTime(reminderTime.getTime() + 5 * 60 * 1000); // 5 minutes later for testing

  await notificationService.createAppointmentReminder(
    user,
    {
      serviceName: 'Driver License Renewal',
      departmentName: 'Department of Transportation',
      appointmentDate: formattedDate,
      appointmentTime: '10:30 AM',
      location: '123 Government Center, Floor 2, Room 245',
      referenceNumber: 'APT-12345',
      requiredDocuments: [
        'Current driver license',
        'Proof of address (utility bill, bank statement, etc.)',
        'Social security card or passport',
        'Vision test results (if applicable)',
        'Medical certificate (if required)',
      ],
      qrCodeUrl: 'https://example.com/qr/12345',
    },
    reminderTime,
  );

  // 4. Status update - application in progress
  await notificationService.createStatusUpdate(user, {
    status: 'In Progress',
    statusClass: 'status-in-progress',
    serviceName: 'Business Permit Application',
    departmentName: 'Department of Commerce',
    referenceNumber: 'BPA-9876',
    updateDate: new Date().toLocaleDateString(),
    officerName: 'Sarah Johnson',
    message:
      'Your application is being processed. We will notify you of any updates or additional requirements.',
    isCompleted: false,
  });

  // 5. Status update - document request
  await notificationService.createDocumentRequest(user, {
    serviceName: 'Business Permit Application',
    departmentName: 'Department of Commerce',
    referenceNumber: 'BPA-9876',
    updateDate: new Date().toLocaleDateString(),
    officerName: 'Sarah Johnson',
    message: 'We need additional documents to process your application.',
    additionalDocuments: [
      'Tax clearance certificate',
      'Fire safety inspection report',
      'Business ownership proof',
    ],
    deadline: new Date(
      new Date().setDate(new Date().getDate() + 14),
    ).toLocaleDateString(),
    portalUrl: 'https://govconnect.example.com/services/upload/BPA-9876',
  });

  // 6. Status update - completed
  await notificationService.createStatusUpdate(user, {
    status: 'Approved',
    statusClass: 'status-approved',
    serviceName: 'Business Permit Application',
    departmentName: 'Department of Commerce',
    referenceNumber: 'BPA-9876',
    updateDate: new Date().toLocaleDateString(),
    officerName: 'Sarah Johnson',
    message:
      'Congratulations! Your Business Permit has been approved. You can download the official permit from your account.',
    isCompleted: true,
    downloadUrl: 'https://govconnect.example.com/documents/permit/BPA-9876',
  });
}
