import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: TextField(
          controller: _searchCtrl,
          style: GoogleFonts.shareTechMono(
            color: FireflyTheme.textOnDark,
            fontSize: 16,
          ),
          decoration: const InputDecoration(
            hintText: "SEARCH USERS...",
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: FireflyTheme.textOnDark,
              ),
            );
          }

          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['uid'] != currentUid &&
                data['username'].toString().toLowerCase().contains(_searchText);
          }).toList();

          if (users.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "NO USERS FOUND",
                  style: GoogleFonts.shareTechMono(
                    color: FireflyTheme.textOnDark,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final uid = user['uid'];
              final username = user['username'];
              final isEven = index.isEven;

              return StreamBuilder<String>(
                stream: requestService.checkStatus(uid),
                builder: (context, statusSnap) {
                  String status = statusSnap.data ?? 'none';

                  return Container(
                    color: isEven
                        ? FireflyTheme.darkBlock
                        : FireflyTheme.lightBlock,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username.toUpperCase(),
                                style: GoogleFonts.anton(
                                  color: isEven
                                      ? FireflyTheme.textOnDark
                                      : FireflyTheme.textOnLight,
                                  fontSize: 18,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                user['email'],
                                style: GoogleFonts.shareTechMono(
                                  color: isEven
                                      ? FireflyTheme.textOnDark
                                      : FireflyTheme.textOnLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildActionButton(
                          status,
                          uid,
                          username,
                          requestService,
                          isEven,
                        ),
                      ],
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
    bool isEven,
  ) {
    switch (status) {
      case 'pending':
        return Container(
          color: isEven
              ? FireflyTheme.lightBlock
              : FireflyTheme.darkBlock,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            "SENT",
            style: GoogleFonts.shareTechMono(
              color: isEven
                  ? FireflyTheme.textOnLight
                  : FireflyTheme.textOnDark,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        );
      case 'accepted':
        return Container(
          color: isEven
              ? FireflyTheme.lightBlock
              : FireflyTheme.darkBlock,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            "✓ FRIENDS",
            style: GoogleFonts.anton(
              color: isEven
                  ? FireflyTheme.textOnLight
                  : FireflyTheme.textOnDark,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        );
      default:
        return GestureDetector(
          onTap: () => service.sendRequest(uid, name),
          child: Container(
            color: isEven
                ? FireflyTheme.lightBlock
                : FireflyTheme.darkBlock,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              "REQUEST",
              style: GoogleFonts.anton(
                color: isEven
                    ? FireflyTheme.textOnLight
                    : FireflyTheme.textOnDark,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        );
    }
  }
}
