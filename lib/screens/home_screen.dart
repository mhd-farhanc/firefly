import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: FireflyTheme.darkBlock,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          "LOG OUT",
          style: GoogleFonts.anton(
            color: FireflyTheme.textOnDark,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          "ARE YOU SURE YOU WANT TO LOG OUT?",
          style: GoogleFonts.shareTechMono(color: FireflyTheme.textOnDark),
        ),
        actions: [
          TextButton(
            child: Text(
              "CANCEL",
              style: GoogleFonts.shareTechMono(color: FireflyTheme.textOnDark),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              "LOG OUT",
              style: GoogleFonts.shareTechMono(color: FireflyTheme.textOnDark),
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
        title: const Text("FIREFLY"),
        backgroundColor: FireflyTheme.darkBlock,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        actions: [
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
                      MaterialPageRoute(
                        builder: (_) => const RequestsScreen(),
                      ),
                    ),
                  ),
                  if (hasRequests)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: FireflyTheme.lightBlock,
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
        backgroundColor: FireflyTheme.lightBlock,
        foregroundColor: FireflyTheme.textOnLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: const Icon(Icons.search),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: FireflyTheme.textOnDark,
              ),
            );
          }

          var myChats = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['fromId'] == currentUser!.uid ||
                data['toId'] == currentUser.uid;
          }).toList();

          if (myChats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "NO CHATS YET.\nSEARCH FOR FRIENDS!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    color: FireflyTheme.textOnDark,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: myChats.length,
            itemBuilder: (context, index) {
              final data = myChats[index].data() as Map<String, dynamic>;
              final isMeSender = data['fromId'] == currentUser!.uid;

              String otherName = isMeSender
                  ? (data['toName'] ?? "Unknown")
                  : (data['fromName'] ?? "Unknown");
              final otherId = isMeSender ? data['toId'] : data['fromId'];

              final isEven = index.isEven;

              return GestureDetector(
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
                child: Container(
                  color: isEven
                      ? FireflyTheme.darkBlock
                      : FireflyTheme.lightBlock,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Container(
                        color: isEven
                            ? FireflyTheme.lightBlock
                            : FireflyTheme.darkBlock,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Text(
                          otherName[0].toUpperCase(),
                          style: GoogleFonts.anton(
                            color: isEven
                                ? FireflyTheme.textOnLight
                                : FireflyTheme.textOnDark,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              otherName.toUpperCase(),
                              style: GoogleFonts.anton(
                                color: isEven
                                    ? FireflyTheme.textOnDark
                                    : FireflyTheme.textOnLight,
                                fontSize: 18,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "TAP TO CHAT",
                              style: GoogleFonts.shareTechMono(
                                color: isEven
                                    ? FireflyTheme.textOnDark
                                    : FireflyTheme.textOnLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
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
