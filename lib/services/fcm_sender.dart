import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/src/service_account_client.dart'
    show clientViaServiceAccount;
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmSender {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final ServiceAccountCredentials _credentials =
      ServiceAccountCredentials.fromJson(_serviceAccountJson);

  static const String _projectId = 'firefly-11f82';
  static const String _fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  static AutoRefreshingAuthClient? _authClient;

  static Future<AutoRefreshingAuthClient> _getClient() async {
    _authClient ??= await clientViaServiceAccount(
      _credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );
    return _authClient!;
  }

  static Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final client = await _getClient();

      final response = await client.post(
        Uri.parse(_fcmEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data,
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('FCM send failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('FCM send error: $e');
    }
  }

  static Future<void> notifyReceiver({
    required String receiverId,
    required String senderName,
    required String messageText,
    required String senderId,
  }) async {
    try {
      final receiverDoc =
          await _firestore.collection('users').doc(receiverId).get();
      if (!receiverDoc.exists) return;

      final fcmToken = receiverDoc.data()?['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      await sendNotification(
        fcmToken: fcmToken,
        title: senderName,
        body: messageText,
        data: {
          'senderId': senderId,
          'senderName': senderName,
        },
      );
    } catch (e) {
      debugPrint('notifyReceiver error: $e');
    }
  }

  static const Map<String, dynamic> _serviceAccountJson = {
    "type": "service_account",
    "project_id": "firefly-11f82",
    "private_key_id": "5961dabd0785c1247e9c55d2c6821d35f651a60b",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDaXyIej53Fz7Gw\n+y0MNCUh7rJ3ChZd9IVy1LECqbKPu0ESzYCARMx+wHMwlVm/KQEPNTRvLi25dZ9V\nVrEY2B2KKww6M25YzvLcm0pdBfT2qBSv6Owq8bCbuq9NWmUZY7Yq4/RQ/TRdQLpm\naWrr9+Liid61zn+3FbSXclCfbftX2NTx8krHpTjuUdS+Wk40cYbvQ0ZX+5vjx/Me\n6Um1uIklAEv57V2IgnnnO6MnQEkNFZBXALBXFyBJCoy17xeeeCV2JQZJDvqeojGb\n0BDWhwIS77tvq3V2frr4e6DeoSyan8S02ePDzRe9hWc8hMfADp3O2JlMdwS3//wl\nXimGoMxJAgMBAAECggEADxZ+4OHvJp9bsYTfR040iRhJGia3Jil6jXUy4EJZmSr4\n22vZvrMSNolFRDRzgZzbiwGT9IEaLWvaNQ8i+BqZiuX/x6ctTwNIfjPYEt6SHvc8\ny60yISL3HwFqcpOl89fC+spqg2yFQVKzNld/CNwFH/4i5kik5CFiq4qdVbCnirmK\nyhtxPTbcMYk5XwMKyPiMPcZZBR12aW1lYh07fkiTmht/7voxRWXoKRjj/w8q4nmZ\n8V619Ld7pB6ir5J2Pup07hEDdbYjO25rot3h3lDqOnDtROwwm6SlpRfPd9X/G+IF\nUHfnRYQqmSGOpyr301bhuvMhPTxseXl9VL8FHdivYQKBgQDxOddEKzyxw859n3pI\nA+ZlU/THnz4SeM8a8zlophuBcXwHAhNVSn67y8uwot7fkSD5I51vkjMGLXMDs0Bc\nJZcyg3fpUYe0kVUCm5ML8GmrilMbgcxNtd4fBbLRsUOF0XzXAIOsz7ZW5k1Hcm0v\n74pJcqy/LOEsD45esJYybpU8aQKBgQDnvvYm8pAYDSPy61HQPWaP3jm8oyFynKur\ng5mu0Gq2fd2iugJB4AdCNZUD5cZhcOdNZvtZu9A+rjODfIz6DMAGmY0XYqwA9F4l\nwyhgn6fBdvFYcQIZfmVNHgBUr0eI+/C/yLg71Y5ec7jW7HAOsP5ixaHS79Mlr7Qe\ncVywkPqU4QKBgEnKt99Smq6Gh5RGRNHi34f/ttGaFRLxgelsnhM1PRTL8nTyXZep\nwjsQjK7sI+GgM8YC7xZCUvmAzb5EB1wo46fAL95f4nOKQccacFEmqiyfk+zGOAlN\nqTU0OQ+MemtlOhtLPPyQTecnbFx+1IflbxgozE9vGzKvT44H1up2iZCBAoGBAJa8\nu1dyBw/d3DgxoDGW/pMttNhiM2tdRLx3CQuQPRkenX8vBjDbC12hhJ/YYUUYLxtF\nlNA1ParHnHI2HWy3xl+EmSVQ5Rhp2qMtYaIXtwI735frSbZTZIjYrtZmfF05osrc\nQBmLOuNs2hnSCMFFlvGgIzYVEH4+3yW+DtA6PQOBAoGASCanqu3Vfnfn4T1ew1i+\nD1FlhVeVgB6EF6MY1C8BUWSkU2bj5Hy1Ffcam4ycvLFNP6rTohzbTFZI2lh6Q9IJ\n41GnJcg7zmHSUHlnoAisGCxYDrj4bZ4yBh37u8PZBT8AEnKR7EXt8oYqCxr9LiTk\n+HNmBEpnNg5R/K35ntMhBLI=\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-fbsvc@firefly-11f82.iam.gserviceaccount.com",
    "client_id": "111478792884211496115",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40firefly-11f82.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com",
  };
}
