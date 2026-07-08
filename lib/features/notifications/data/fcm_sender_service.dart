import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FcmSenderService {
  static const _projectId = 'all-features-project';
  static const _fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Replace this with your actual downloaded service account JSON string
  static const _serviceAccountJson = '''
{
  "type": "service_account",
  "private_key": "-----BEGIN PRIVATE KEY----- ...",
  ...
}
''';

  static Future<String?> _getAccessToken() async {
    return null;
  }

  static Future<void> sendNotification({
    required String targetFcmToken,
    required String title,
    required String body,
    required String chatId,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        print("Could not get OAuth2 token to send FCM message.");
        return;
      }

      final payload = {
        'message': {
          'token': targetFcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'chatId': chatId,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          }
        }
      };

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Client-side Push Notification sent successfully!');
      } else {
        print('Failed to send notification: \${response.body}');
      }
    } catch (e) {
      print('Exception while sending notification: \$e');
    }
  }
}
