# FIREFLY

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/github/license/mhd-farhanc/firefly?style=for-the-badge" alt="License" />
</p>

<p align="center">
  A real-time messaging application built with Flutter and Firebase. Features a bold, high-contrast brutalist architectural design with a friend request system for secure and private chats.
</p>

---

## FEATURES

- **Real-time Messaging** - Instant delivery using Cloud Firestore streams.
- **Push Notifications** - FCM notifications sent directly from client via Firebase Admin SDK service account. No Cloud Functions required — works on Spark plan.
- **Secure Authentication** - Email & password login/signup powered by Firebase Auth.
- **Friend System**
  - Search for users by username.
  - Send, accept, and reject friend requests.
  - "Pending Request" notification badge.
- **Brutalist UI**
  - Electric orange/red canvas (`#FF3B00`).
  - Stark black and white structural blocks.
  - Anton display typography for headings, ShareTechMono for body text.
  - Zero border radius, no shadows, no glass effects.

## TECH STACK

- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Firestore, Authentication, Cloud Messaging)
- **State Management:** Provider
- **Typography:** Google Fonts (Anton & ShareTechMono)
- **Notifications:** firebase_messaging, flutter_local_notifications, googleapis_auth

## GETTING STARTED

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mhd-farhanc/firefly.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Firebase Setup:**
   Configure your own Firebase project:
   ```bash
   flutterfire configure
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

## CONTRIBUTING

Contributions, issues, and feature requests are welcome!

---

<p align="center">Created by <a href="https://github.com/mhd-farhanc">Muhammed Farhan C</a></p>
