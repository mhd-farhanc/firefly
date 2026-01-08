import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get correct room ID
  String getRoomId(String userId) {
    final currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, userId];
    ids.sort();
    return ids.join('_');
  }

  // Send Message
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
  }

  // Get Messages Stream
  Stream<QuerySnapshot> getMessages(String receiverId) {
    final roomId = getRoomId(receiverId);

    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Oldest top, newest bottom
        .snapshots();
  }
}
