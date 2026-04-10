import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_models.dart';
import '../models/user_model.dart';
import '../controllers/room_chat_controller.dart';
import '../services/community_service.dart';
import '../widgets/deaf_theme.dart';
import '../widgets/profile_barrier.dart';
import 'package:intl/intl.dart';

class RoomChatScreen extends StatefulWidget {
  final RoomModel room;
  final UserModel user;

  const RoomChatScreen({super.key, required this.room, required this.user});

  @override
  State<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends State<RoomChatScreen> {
  late RoomChatController _controller;
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = RoomChatController(
      service: CommunityService(),
      roomId: widget.room.id,
      userId: widget.user.uid,
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    ProfileBarrier.check(context, widget.user, () {
      if (_msgController.text.trim().isEmpty) return;

      final msg = RoomMessageModel(
        id: '',
        userId: widget.user.uid,
        userName: widget.user.name,
        userEmoji: widget.user.profileEmoji,
        text: _msgController.text.trim(),
        createdAt: DateTime.now(),
      );

      _controller.sendMessage(msg);
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeafTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.room.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ChangeNotifierProvider.value(
              value: _controller,
              child: Consumer<RoomChatController>(
                builder: (context, controller, child) {
                  return Text(
                    '🟢 ${controller.activeCount} active now',
                    style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ],
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChangeNotifierProvider.value(
              value: _controller,
              child: Consumer<RoomChatController>(
                builder: (context, controller, child) {
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, i) {
                      final msg = controller.messages[i];
                      final bool isMe = msg.userId == widget.user.uid;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                },
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(RoomMessageModel msg, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              alignment: Alignment.center,
              child: Text(msg.userEmoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(msg.userName, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? DeafTheme.orangeA : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                  child: Text(
                    DateFormat('hh:mm a').format(msg.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              alignment: Alignment.center,
              child: Text(msg.userEmoji, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _msgController,
                  decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: DeafTheme.orangeA),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
