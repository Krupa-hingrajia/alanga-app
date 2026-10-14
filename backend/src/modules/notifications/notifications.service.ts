import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { FirebaseAdminService } from './firebase-admin.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseAdmin: FirebaseAdminService,
  ) {}

  /**
   * Register or update an FCM token for a user
   */
  async registerToken(userId: string, token: string, deviceType = 'ANDROID') {
    try {
      return await this.prisma.fcmToken.upsert({
        where: { token },
        update: {
          userId,
          deviceType: deviceType.toUpperCase(),
          updatedAt: new Date(),
        },
        create: {
          userId,
          token,
          deviceType: deviceType.toUpperCase(),
        },
      });
    } catch (error) {
      this.logger.error(`Failed to register FCM token: ${error.message}`);
      throw error;
    }
  }

  /**
   * Remove an FCM token (e.g. on logout)
   */
  async removeToken(token: string) {
    try {
      await this.prisma.fcmToken.deleteMany({
        where: { token },
      });
      return { success: true };
    } catch (error) {
      this.logger.error(`Failed to remove FCM token: ${error.message}`);
      return { success: false };
    }
  }

  /**
   * Send notification to a specific user (saves to DB and sends push)
   */
  async sendNotificationToUser(
    userId: string,
    title: string,
    body: string,
    type = 'GENERAL',
    data?: Record<string, any>,
  ) {
    try {
      // 1. Save in database
      const notification = await this.prisma.notification.create({
        data: {
          userId,
          title,
          body,
          type,
          data: data ? data : undefined,
        },
      });

      // 2. Fetch user's active FCM tokens
      const userTokens = await this.prisma.fcmToken.findMany({
        where: { userId },
        select: { token: true },
      });

      if (userTokens.length > 0) {
        const tokensList = userTokens.map((t) => t.token);
        const pushData = {
          notificationId: notification.id,
          type,
          ...(data || {}),
        };

        const result = await this.firebaseAdmin.sendPushToTokens(
          tokensList,
          { title, body },
          pushData,
        );

        // Clean up invalid or un-registered tokens if any
        if (result.failedTokens.length > 0) {
          await this.prisma.fcmToken.deleteMany({
            where: { token: { in: result.failedTokens } },
          });
          this.logger.log(`Cleaned up ${result.failedTokens.length} expired FCM tokens.`);
        }
      }

      return notification;
    } catch (error) {
      this.logger.error(`Error sending notification to user ${userId}: ${error.message}`);
      // Return null or throw depending on caller, but don't crash main flows
      return null;
    }
  }

  /**
   * Get paginated notifications for a user
   */
  async getUserNotifications(userId: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [notifications, total, unreadCount] = await Promise.all([
      this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.notification.count({
        where: { userId },
      }),
      this.prisma.notification.count({
        where: { userId, isRead: false },
      }),
    ]);

    return {
      notifications,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
      unreadCount,
    };
  }

  /**
   * Get unread notifications count for badge display
   */
  async getUnreadCount(userId: string): Promise<number> {
    return this.prisma.notification.count({
      where: { userId, isRead: false },
    });
  }

  /**
   * Mark a single notification as read
   */
  async markAsRead(userId: string, notificationId: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found.');
    }

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });
  }

  /**
   * Mark all notifications as read for a user
   */
  async markAllAsRead(userId: string) {
    await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });

    return { success: true };
  }

  /**
   * Delete a notification
   */
  async deleteNotification(userId: string, notificationId: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found.');
    }

    await this.prisma.notification.delete({
      where: { id: notificationId },
    });

    return { success: true };
  }
}
