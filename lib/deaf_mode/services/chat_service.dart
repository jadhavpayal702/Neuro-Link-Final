import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getOrCreateChat(String uid1, String uid2) async {
    final chatId = ChatModel.generateChatId(uid1, uid2);
    final doc = await _db.collection('chats').doc(chatId).get();
    
    if (!doc.exists) {
      final chat = ChatModel(
        chatId: chatId,
        participants: [uid1, uid2],
        lastMessage: '',
      );
      await _db.collection('chats').doc(chatId).set(chat.toMap());
    }
    
    return chatId;
  }

  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _db.collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    final messageRef = _db.collection('chats').doc(chatId).collection('messages').doc();
    await messageRef.set(message.toMap());
    
    // Update last message in chat document
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addReaction(String chatId, String messageId, String userId, String emoji) async {
    await _db.collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$userId': emoji,
    });
  }
}
