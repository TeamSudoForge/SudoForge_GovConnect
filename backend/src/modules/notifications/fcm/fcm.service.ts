import { Injectable, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';
import * as fs from 'fs';

interface FcmPayload {
  token: string;
  title: string;
  body: string;
  data?: Record<string, any>;
}

// Initialize Firebase Admin SDK once
let firebaseInitialized = false;
const logger = new Logger('FcmService');

try {
  const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
    path.join(
      __dirname,
      '../../../config/firebase/firebase-service-account.json',
    );
  
  // Check if the service account file exists and is valid
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
    
    // Validate that the private key is properly formatted
    if (serviceAccount.private_key && serviceAccount.private_key.includes('BEGIN PRIVATE KEY') && serviceAccount.private_key.includes('END PRIVATE KEY')) {
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert(serviceAccountPath),
        });
        firebaseInitialized = true;
        logger.log('Firebase Admin SDK initialized successfully');
      }
    } else {
      logger.warn('Firebase service account file has invalid or incomplete private key. FCM notifications will be disabled.');
    }
  } else {
    logger.warn('Firebase service account file not found. FCM notifications will be disabled.');
  }
} catch (error) {
  logger.error('Failed to initialize Firebase Admin SDK:', error.message);
  logger.warn('FCM notifications will be disabled.');
}

@Injectable()
export class FcmService {
  private readonly logger = new Logger(FcmService.name);

  async sendNotification(payload: FcmPayload): Promise<void> {
    if (!firebaseInitialized) {
      this.logger.warn('Skipping FCM notification - Firebase not initialized');
      return;
    }

    const message: admin.messaging.Message = {
      token: payload.token,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data ? payload.data : undefined,
    };
    try {
      await admin.messaging().send(message);
      this.logger.log(`FCM notification sent successfully to token: ${payload.token.substring(0, 10)}...`);
    } catch (error) {
      this.logger.error('FCM send error:', error);
    }
  }
}
