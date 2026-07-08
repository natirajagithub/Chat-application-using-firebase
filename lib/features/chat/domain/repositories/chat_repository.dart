import '../entities/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, String senderId, String text);
  Stream<List<Map<String, dynamic>>> getChatRooms(String userId);
}
