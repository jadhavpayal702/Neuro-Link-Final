import 'package:flutter/foundation.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';

class ChatController extends ChangeNotifier {
  final FirestoreService _firestore;
  final ChatService _chatService;
  final String currentUserUid;

  ChatController(this._firestore, this._chatService, this.currentUserUid);

  List<UserModel> _discoveredUsers = [];
  List<UserModel> get discoveredUsers => _discoveredUsers;

  List<UserModel> _filteredUsers = [];
  List<UserModel> get filteredUsers => _filteredUsers;

  bool _loading = false;
  bool get loading => _loading;

  void filterUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = _discoveredUsers;
    } else {
      _filteredUsers = _discoveredUsers
          .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void updateDiscoveredUsers(List<UserModel> users) {
    _discoveredUsers = users;
    _filteredUsers = users;
    notifyListeners();
  }

  Stream<List<UserModel>> streamUsers() {
    return _firestore.getUsersDiscovery(currentUserUid);
  }

  Future<String> startChat(String otherUserUid) async {
    return await _chatService.getOrCreateChat(currentUserUid, otherUserUid);
  }

  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _chatService.streamMessages(chatId);
  }

  Future<void> sendMessage(String chatId, String text) async {
    final message = MessageModel(
      messageId: '', // Firestore will generate
      senderId: currentUserUid,
      text: text,
      timestamp: DateTime.now(),
    );
    await _chatService.sendMessage(chatId, message);
  }

  Future<void> addReaction(String chatId, String messageId, String emoji) async {
    await _chatService.addReaction(chatId, messageId, currentUserUid, emoji);
  }
}
