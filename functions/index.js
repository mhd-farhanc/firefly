const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendMessageNotification = functions.firestore
    .document('chat_rooms/{roomId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
      const messageData = snap.data();
      const senderId = messageData.senderId;
      const text = messageData.text;

      if (!senderId || !text) return;

      const roomId = context.params.roomId;
      const ids = roomId.split('_');
      const receiverId = ids[0] === senderId ? ids[1] : ids[0];

      if (!receiverId) return;

      try {
        const senderDoc = await admin.firestore()
            .collection('users')
            .doc(senderId)
            .get();

        const senderName = senderDoc.exists
            ? (senderDoc.data().username || 'Someone')
            : 'Someone';

        const receiverDoc = await admin.firestore()
            .collection('users')
            .doc(receiverId)
            .get();

        if (!receiverDoc.exists) return;
        const fcmToken = receiverDoc.data().fcmToken;
        if (!fcmToken) return;

        const message = {
          notification: {
            title: senderName,
            body: text,
          },
          data: {
            senderId: senderId,
            senderName: senderName,
          },
          token: fcmToken,
        };

        await admin.messaging().send(message);
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    });
