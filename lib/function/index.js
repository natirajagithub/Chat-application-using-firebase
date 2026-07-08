const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationOnMessage = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const senderId = message.senderId;
    const text = message.text;
    const chatId = context.params.chatId;

    // Get the chat document to find the other participant
    const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
    const participants = chatDoc.data().participants;

    // Find the receiver's ID
    const receiverId = participants.find((id) => id !== senderId);

    if (!receiverId) return null;

    // Get the receiver's FCM Token and the Sender's name
    const [receiverDoc, senderDoc] = await Promise.all([
      admin.firestore().collection("users").doc(receiverId).get(),
      admin.firestore().collection("users").doc(senderId).get(),
    ]);

    const fcmToken = receiverDoc.data().fcmToken;
    const senderName = senderDoc.data().name || "Someone";

    if (!fcmToken) {
      console.log("No FCM token for user, cannot send notification.");
      return null;
    }

    // Create the Notification Payload
    const payload = {
      notification: {
        title: senderName,
        body: text,
      },
      data: {
        chatId: chatId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    // Send the Notification!
    return admin.messaging().sendToDevice(fcmToken, payload);
  });