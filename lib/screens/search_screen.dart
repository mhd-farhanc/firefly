import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final requestService = RequestService();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search users...", // Friendly text
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: FireflyTheme.red),
            );

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['uid'] != currentUid &&
                data['username'].toString().toLowerCase().contains(_searchText);
          }).toList();

          if (users.isEmpty) {
            return const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final uid = user['uid'];
              final username = user['username']; // Get the name

              return StreamBuilder<String>(
                stream: requestService.checkStatus(uid),
                builder: (context, statusSnap) {
                  String status = statusSnap.data ?? 'none';

                  return ListTile(
                    title: Text(
                      username,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      user['email'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    // Pass username to the button builder
                    trailing: _buildActionButton(
                      status,
                      uid,
                      username,
                      requestService,
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

  Widget _buildActionButton(
    String status,
    String uid,
    String name,
    RequestService service,
  ) {
    switch (status) {
      case 'pending':
        return const Text("Sent", style: TextStyle(color: Colors.grey));
      case 'accepted':
        return const Icon(Icons.check_circle, color: FireflyTheme.red);
      default:
        return ElevatedButton(
          child: const Text("Request"),
          onPressed: () =>
              service.sendRequest(uid, name), // FIXED: Passing name
        );
    }
  }
}
