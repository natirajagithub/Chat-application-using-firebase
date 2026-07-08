const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const senderId = message.senderId;
    const text = message.text;
    const chatId = context.params.chatId;

    // Get chat participants
    const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
    const participants = chatDoc.data().participants;
    const receiverId = participants.find(id => id !== senderId);

    if (!receiverId) return null;

    // Get receiver's FCM token
    const receiverDoc = await admin.firestore().collection('users').doc(receiverId).get();
    const fcmToken = receiverDoc.data().fcmToken;

    if (!fcmToken) {
      console.log('No FCM token for user, cannot send notification');
      return null;
    }

    // Get sender's name
    const senderDoc = await admin.firestore().collection('users').doc(senderId).get();
    const senderName = senderDoc.data().name || 'New Message';

    // Send notification
    const payload = {
      notification: {
        title: senderName,
        body: text,
      },
      token: fcmToken,
    };

    try {
      await admin.messaging().send(payload);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }

    return null;
  });
