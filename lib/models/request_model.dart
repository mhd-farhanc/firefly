class ChatRequest {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName; // Added this!
  final String status;

  ChatRequest({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromId': fromId,
      'fromName': fromName,
      'toId': toId,
      'toName': toName,
      'status': status,
    };
  }

  factory ChatRequest.fromMap(Map<String, dynamic> map) {
    return ChatRequest(
      fromId: map['fromId'] ?? '',
      fromName: map['fromName'] ?? 'Unknown',
      toId: map['toId'] ?? '',
      toName: map['toName'] ?? 'Unknown', // Handle old data safely
      status: map['status'] ?? 'pending',
    );
  }
}
