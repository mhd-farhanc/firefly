import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import 'fcm_sender.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getRoomId(String userId) {
    final currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, userId];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage(String receiverId, String text) async {
    final currentUserId = _auth.currentUser!.uid;
    final roomId = getRoomId(receiverId);

    Message message = Message(
      senderId: currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());

    final currentUserDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    final senderName = currentUserDoc.data()?['username'] ?? 'Someone';

    FcmSender.notifyReceiver(
      receiverId: receiverId,
      senderName: senderName,
      messageText: text,
      senderId: currentUserId,
    );
  }

  Stream<QuerySnapshot> getMessages(String receiverId) {
    final roomId = getRoomId(receiverId);

    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
