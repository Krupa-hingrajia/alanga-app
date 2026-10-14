import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { getApps, initializeApp, cert, App } from 'firebase-admin/app';
import { getMessaging, MulticastMessage, SendResponse } from 'firebase-admin/messaging';
import * as path from 'path';
import * as fs from 'fs';

import { ALANGA_FIREBASE_CREDENTIALS } from './firebase-credentials';

@Injectable()
export class FirebaseAdminService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseAdminService.name);
  private firebaseApp: App | null = null;

  onModuleInit() {
    this.initializeFirebase();
  }

  private initializeFirebase() {
    try {
      const apps = getApps();
      if (apps.length > 0) {
        this.firebaseApp = apps[0];
        this.logger.log('Firebase Admin already initialized.');
        return;
      }

      let serviceAccount: any = null;

      // 1. Check if provided via FIREBASE_SERVICE_ACCOUNT environment variable
      if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        try {
          const raw = process.env.FIREBASE_SERVICE_ACCOUNT.trim();
          serviceAccount = raw.startsWith('{')
            ? JSON.parse(raw)
            : JSON.parse(Buffer.from(raw, 'base64').toString('utf8'));
        } catch (e: any) {
          this.logger.warn(`Failed to parse FIREBASE_SERVICE_ACCOUNT env: ${e.message}`);
        }
      }

      // 2. Check for service account file in local paths
      if (!serviceAccount) {
        const potentialPaths = [
          path.join(process.cwd(), 'firebase-service-account.json'),
          path.join(__dirname, '../../../firebase-service-account.json'),
          path.join(__dirname, '../../../../firebase-service-account.json'),
        ];

        for (const p of potentialPaths) {
          if (fs.existsSync(p)) {
            try {
              serviceAccount = JSON.parse(fs.readFileSync(p, 'utf8'));
              this.logger.log(`Using Firebase service account from file: ${p}`);
              break;
            } catch (_) {}
          }
        }
      }

      // 3. Fallback to built-in project credentials (for Cloud Run production container)
      if (!serviceAccount) {
        serviceAccount = ALANGA_FIREBASE_CREDENTIALS;
        this.logger.log('Using built-in Alanga Firebase project service account credentials.');
      }

      this.firebaseApp = initializeApp({
        credential: cert(serviceAccount),
      });
      this.logger.log('Firebase Admin initialized successfully.');
    } catch (error: any) {
      this.logger.error(`Error initializing Firebase Admin SDK: ${error.message}`, error.stack);
    }
  }

  /**
   * Send FCM push notification to multiple tokens (multicast)
   */
  async sendPushToTokens(
    tokens: string[],
    payload: { title: string; body: string },
    data?: Record<string, string>,
  ): Promise<{ failedTokens: string[]; successCount: number }> {
    if (!this.firebaseApp || tokens.length === 0) {
      return { failedTokens: [], successCount: 0 };
    }

    try {
      const stringData: Record<string, string> = {};
      if (data) {
        for (const [key, value] of Object.entries(data)) {
          stringData[key] = typeof value === 'string' ? value : JSON.stringify(value);
        }
      }

      const message: MulticastMessage = {
        tokens,
        notification: {
          title: payload.title,
          body: payload.body,
        },
        data: stringData,
        android: {
          priority: 'high',
          notification: {
            channelId: 'alanga_vendor_notifications',
            priority: 'max',
            defaultSound: true,
            defaultVibrateTimings: true,
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              contentAvailable: true,
            },
          },
        },
      };

      const messaging = getMessaging(this.firebaseApp);
      const response = await messaging.sendEachForMulticast(message);
      const failedTokens: string[] = [];

      response.responses.forEach((resp: SendResponse, idx: number) => {
        if (!resp.success) {
          const errCode = resp.error?.code;
          if (
            errCode === 'messaging/invalid-registration-token' ||
            errCode === 'messaging/registration-token-not-registered'
          ) {
            failedTokens.push(tokens[idx]);
          }
          this.logger.warn(`FCM send error for token [${tokens[idx].substring(0, 10)}...]: ${resp.error?.message}`);
        }
      });

      this.logger.log(
        `FCM multicast sent: ${response.successCount} succeeded, ${response.failureCount} failed out of ${tokens.length}`,
      );

      return {
        failedTokens,
        successCount: response.successCount,
      };
    } catch (error: any) {
      this.logger.error(`FCM multicast failed: ${error.message}`);
      return { failedTokens: [], successCount: 0 };
    }
  }
}
