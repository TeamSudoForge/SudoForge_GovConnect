import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

interface FcmPayload {
  token: string;
  title: string;
  body: string;
  data?: Record<string, any>;
}

// Initialize Firebase Admin SDK once
const serviceAccountPath =
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH ||
  path.join(
    __dirname,
    '../../../config/firebase/firebase-service-account.json',
  );
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath),
  });
}

@Injectable()
export class FcmService {
  async sendNotification(payload: FcmPayload): Promise<void> {
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
    } catch (error) {
      console.error('FCM send error:', error);
    }
  }
}
