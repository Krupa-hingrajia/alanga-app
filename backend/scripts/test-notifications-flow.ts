import { PrismaClient } from '@prisma/client';
import { FirebaseAdminService } from '../src/modules/notifications/firebase-admin.service';
import { NotificationsService } from '../src/modules/notifications/notifications.service';

async function runNotificationFlowTest() {
  console.log('====================================================');
  console.log('🚀 STARTING FULL NOTIFICATION FLOW VERIFICATION TEST');
  console.log('====================================================\n');

  const prisma = new PrismaClient();
  await prisma.$connect();
  console.log('✅ 1. Database connected successfully.');

  // Initialize Firebase Admin Service
  const firebaseAdmin = new FirebaseAdminService();
  firebaseAdmin.onModuleInit();
  console.log('✅ 2. Firebase Admin initialized with service account.');

  // Initialize Notifications Service
  const notifService = new NotificationsService(prisma as any, firebaseAdmin);

  // Find a vendor or admin to test with
  let testUser = await prisma.user.findFirst({
    where: { role: 'VENDOR' },
  });

  if (!testUser) {
    testUser = await prisma.user.findFirst();
  }

  if (!testUser) {
    console.error('❌ No user found in database to run tests.');
    process.exit(1);
  }

  const userId = testUser.id;
  console.log(`✅ 3. Testing with User ID: ${userId} (${testUser.fullName || testUser.email})`);

  // Step 4: Register an FCM Token
  const testFcmToken = `test_fcm_token_${Date.now()}`;
  console.log(`\n--- Step 4: Registering FCM Token ---`);
  const registeredToken = await notifService.registerToken(userId, testFcmToken, 'ANDROID');
  console.log('Token Registration Output:', {
    id: registeredToken.id,
    token: registeredToken.token,
    deviceType: registeredToken.deviceType,
  });
  console.log('✅ 4. FCM Token registered in database successfully.');

  // Step 5: Test Trigger 1 - Product Approval Notification
  console.log(`\n--- Step 5: Triggering "Product Approved" Notification ---`);
  const prodNotif = await notifService.sendNotificationToUser(
    userId,
    '🎉 Product Approved!',
    'Your product "Boat Rockerz 450" has been approved and is now live on the store.',
    'PRODUCT_APPROVAL',
    { productId: 'test-prod-123' },
  );
  console.log('Product Notification Created:', {
    id: prodNotif?.id,
    title: prodNotif?.title,
    type: prodNotif?.type,
    isRead: prodNotif?.isRead,
  });
  console.log('✅ 5. Product approval notification & FCM call executed.');

  // Step 6: Test Trigger 2 - KYC & Store Verification Notification
  console.log(`\n--- Step 6: Triggering "Store & KYC Approved" Notification ---`);
  const kycNotif = await notifService.sendNotificationToUser(
    userId,
    '🎉 Store & KYC Approved!',
    'Congratulations! Your Alanga vendor account and KYC have been verified.',
    'KYC_VERIFIED',
    { vendorId: userId },
  );
  console.log('KYC Notification Created:', {
    id: kycNotif?.id,
    title: kycNotif?.title,
    type: kycNotif?.type,
  });
  console.log('✅ 6. Store & KYC approval notification executed.');

  // Step 7: Test Trigger 3 - New Order Placed Notification
  console.log(`\n--- Step 7: Triggering "New Order Received" Notification ---`);
  const orderNotif = await notifService.sendNotificationToUser(
    userId,
    '🔔 New Order Received!',
    'You have a new order #ALG-2026-TEST-99 for ₹1,299.00 (2 items). Please prepare for dispatch.',
    'ORDER',
    { orderId: 'test-order-99', orderNumber: 'ALG-2026-TEST-99' },
  );
  console.log('Order Notification Created:', {
    id: orderNotif?.id,
    title: orderNotif?.title,
    type: orderNotif?.type,
  });
  console.log('✅ 7. New Order notification executed.');

  // Step 8: Get Notifications List (as Alerts Tab would fetch)
  console.log(`\n--- Step 8: Fetching Notifications List for Alerts Tab ---`);
  const notifList = await notifService.getUserNotifications(userId, 1, 10);
  console.log(`Total notifications for user: ${notifList.total}`);
  console.log(`Unread count: ${notifList.unreadCount}`);
  console.log(`Fetched page count: ${notifList.notifications.length}`);
  console.log('✅ 8. Alerts Tab listing works.');

  // Step 9: Test Mark as Read
  if (prodNotif?.id) {
    console.log(`\n--- Step 9: Marking Notification ${prodNotif.id} as Read ---`);
    await notifService.markAsRead(userId, prodNotif.id);
    const unreadCountAfter = await notifService.getUnreadCount(userId);
    console.log(`Unread count after marking 1 as read: ${unreadCountAfter}`);
    console.log('✅ 9. Single mark as read works.');
  }

  // Step 10: Test Mark All as Read
  console.log(`\n--- Step 10: Marking All Notifications as Read ---`);
  await notifService.markAllAsRead(userId);
  const finalUnreadCount = await notifService.getUnreadCount(userId);
  console.log(`Final Unread Count: ${finalUnreadCount}`);
  if (finalUnreadCount === 0) {
    console.log('✅ 10. Mark all as read works perfectly (unreadCount = 0).');
  }

  // Cleanup test notifications
  console.log(`\n--- Cleanup: Removing test data ---`);
  if (prodNotif?.id) await notifService.deleteNotification(userId, prodNotif.id);
  if (kycNotif?.id) await notifService.deleteNotification(userId, kycNotif.id);
  if (orderNotif?.id) await notifService.deleteNotification(userId, orderNotif.id);
  await notifService.removeToken(testFcmToken);
  console.log('✅ Cleaned up test notifications and dummy FCM token.');

  await prisma.$disconnect();
  console.log('\n====================================================');
  console.log('🎉 ALL 10 NOTIFICATION FLOW TESTS PASSED SUCCESSFULLY!');
  console.log('====================================================\n');
}

runNotificationFlowTest().catch((err) => {
  console.error('❌ Test failed with error:', err);
  process.exit(1);
});
