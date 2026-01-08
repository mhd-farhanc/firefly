import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/request_service.dart';
import 'search_screen.dart';
import 'chat_screen.dart';
import 'requests_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262626),
        title: const Text("Log Out", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Log Out",
              style: TextStyle(color: FireflyTheme.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final requestService = RequestService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Firefly"),
        backgroundColor: Colors.black,
        actions: [
          // Notifications Icon
          StreamBuilder<List>(
            stream: requestService.getIncomingRequests(),
            builder: (context, snapshot) {
              bool hasRequests = snapshot.hasData && snapshot.data!.isNotEmpty;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RequestsScreen()),
                    ),
                  ),
                  if (hasRequests)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: FireflyTheme.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: FireflyTheme.red,
        child: const Icon(Icons.search, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
      ),
      // Active Chats List
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: FireflyTheme.red),
            );

          // 1. Filter chats where I am a participant
          var myChats = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // FIX: Added '!' to currentUser!.uid to fix the null error
            return data['fromId'] == currentUser!.uid ||
                data['toId'] == currentUser.uid;
          }).toList();

          if (myChats.isEmpty) {
            return const Center(
              child: Text(
                "No chats yet. Search for friends!",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: myChats.length,
            itemBuilder: (context, index) {
              final data = myChats[index].data() as Map<String, dynamic>;

              // FIX: Added '!' here as well
              final isMeSender = data['fromId'] == currentUser!.uid;

              String otherName = isMeSender
                  ? (data['toName'] ?? "Unknown")
                  : (data['fromName'] ?? "Unknown");
              final otherId = isMeSender ? data['toId'] : data['fromId'];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  otherName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  "Tap to chat",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: CircleAvatar(
                  backgroundColor: FireflyTheme.grey,
                  child: Text(
                    otherName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        receiverId: otherId,
                        receiverName: otherName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
