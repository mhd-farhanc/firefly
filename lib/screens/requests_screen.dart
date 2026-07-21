import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: const Text("FRIEND REQUESTS"),
        backgroundColor: FireflyTheme.darkBlock,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      body: StreamBuilder<List<ChatRequest>>(
        stream: requestService.getIncomingRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  "NO PENDING REQUESTS",
                  style: GoogleFonts.shareTechMono(
                    color: FireflyTheme.textOnDark,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final req = snapshot.data![index];
              final isEven = index.isEven;

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
                    Container(
                      color: isEven
                          ? FireflyTheme.lightBlock
                          : FireflyTheme.darkBlock,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Text(
                        req.fromName[0].toUpperCase(),
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
                            req.fromName.toUpperCase(),
                            style: GoogleFonts.anton(
                              color: isEven
                                  ? FireflyTheme.textOnDark
                                  : FireflyTheme.textOnLight,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            "WANTS TO CHAT",
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              requestService.rejectRequest(req.fromId),
                          child: Container(
                            color: isEven
                                ? FireflyTheme.lightBlock
                                : FireflyTheme.darkBlock,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Text(
                              "✕",
                              style: GoogleFonts.anton(
                                color: isEven
                                    ? FireflyTheme.textOnLight
                                    : FireflyTheme.textOnDark,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () =>
                              requestService.acceptRequest(req.fromId),
                          child: Container(
                            color: isEven
                                ? FireflyTheme.lightBlock
                                : FireflyTheme.darkBlock,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Text(
                              "✓",
                              style: GoogleFonts.anton(
                                color: isEven
                                    ? FireflyTheme.textOnLight
                                    : FireflyTheme.textOnDark,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
