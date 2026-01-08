import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/request_model.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send a Request
  Future<void> sendRequest(String receiverId, String receiverName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Fetch my name to send to them
    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final senderName = userDoc.data()?['username'] ?? 'Unknown';

    ChatRequest request = ChatRequest(
      fromId: currentUser.uid,
      fromName: senderName,
      toId: receiverId,
      toName: receiverName,
      status: 'pending',
    );

    String requestId = '${currentUser.uid}_$receiverId';
    await _firestore.collection('requests').doc(requestId).set(request.toMap());
  }

  // Accept Request
  Future<void> acceptRequest(String senderId) async {
    final currentUserId = _auth.currentUser!.uid;
    String requestId = '${senderId}_$currentUserId';

    await _firestore.collection('requests').doc(requestId).update({
      'status': 'accepted',
    });

    List<String> ids = [currentUserId, senderId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': ids,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // REJECT Request (New Feature)
  Future<void> rejectRequest(String senderId) async {
    final currentUserId = _auth.currentUser!.uid;
    String requestId = '${senderId}_$currentUserId';

    // Deletes the request document from the database
    await _firestore.collection('requests').doc(requestId).delete();
  }

  Stream<List<ChatRequest>> getIncomingRequests() {
    final uid = _auth.currentUser?.uid;
    return _firestore
        .collection('requests')
        .where('toId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRequest.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<String> checkStatus(String otherUserId) {
    final myId = _auth.currentUser?.uid;
    return _firestore
        .collection('requests')
        .doc('${myId}_$otherUserId')
        .snapshots()
        .map((doc) {
          if (doc.exists) return doc.data()?['status'] ?? 'none';
          return 'none';
        });
  }
}
