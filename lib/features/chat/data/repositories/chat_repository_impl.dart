import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../notifications/data/fcm_sender_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final message = Message(
      id: '',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );
    
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // --- TRIGGER CLIENT SIDE NOTIFICATION ---
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return;
      
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final receiverId = participants.firstWhere((id) => id != senderId, orElse: () => '');
      
      if (receiverId.isNotEmpty) {
        final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
        final fcmToken = receiverDoc.data()?['fcmToken'] as String?;
        
        if (fcmToken != null && fcmToken.isNotEmpty) {
          final senderDoc = await _firestore.collection('users').doc(senderId).get();
          final senderName = senderDoc.data()?['name'] ?? 'Someone';
          
          // Send FCM using the service we created!
          await FcmSenderService.sendNotification(
            targetFcmToken: fcmToken,
            title: senderName,
            body: text,
            chatId: chatId,
          );
        }
      }
    } catch (e) {
      print('Error triggering client-side notification: \$e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getChatRooms(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
