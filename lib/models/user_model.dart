class FireflyUser {
  final String uid;
  final String email;
  final String username;
  final String searchKey; // Helper for searching

  FireflyUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.searchKey,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'searchKey': searchKey,
    };
  }

  // Create from Firebase Doc
  factory FireflyUser.fromMap(Map<String, dynamic> map) {
    return FireflyUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      searchKey: map['searchKey'] ?? '',
    );
  }
}
