import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';
import '../theme/app_theme.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requestService = RequestService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<ChatRequest>>(
        stream: requestService.getIncomingRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No pending requests",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final req = snapshot.data![index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: FireflyTheme.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      req.fromName[0].toUpperCase(),
                      style: const TextStyle(color: FireflyTheme.red),
                    ),
                  ),
                  title: Text(
                    req.fromName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Wants to chat with you",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reject Button (X)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () =>
                            requestService.rejectRequest(req.fromId),
                      ),
                      // Accept Button (Check)
                      IconButton(
                        icon: const Icon(Icons.check, color: FireflyTheme.red),
                        onPressed: () =>
                            requestService.acceptRequest(req.fromId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
