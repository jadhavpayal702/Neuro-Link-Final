// import 'package:flutter/material.dart';
// import '../models/message_model.dart';
// import '../services/ai_service.dart';
// import '../widgets/deaf_theme.dart';
// import '../widgets/message_bubble.dart';

// class AiChatScreen extends StatefulWidget {
//   const AiChatScreen({super.key});

//   @override
//   State<AiChatScreen> createState() => _AiChatScreenState();
// }

// class _AiChatScreenState extends State<AiChatScreen> {
//   final TextEditingController _input = TextEditingController();
//   final List<MessageModel> _messages = [];
//   final AiService _aiService = AiService();
//   final ScrollController _scrollController = ScrollController();
//   bool _isTyping = false;

//   void _handleSend() async {
//     if (_input.text.trim().isEmpty) return;

//     final userText = _input.text.trim();
//     _input.clear();

//     final userMsg = MessageModel(
//       messageId: DateTime.now().toString(),
//       senderId: 'user',
//       text: userText,
//       timestamp: DateTime.now(),
//     );

//     setState(() {
//       _messages.insert(0, userMsg);
//       _isTyping = true;
//     });

//     _scrollToBottom();

//     // Prepare chat history for AI
//     final history = _messages
//         .reversed
//         .map((m) => {
//               'role': m.senderId == 'user' ? 'user' : 'assistant',
//               'content': m.text,
//             })
//         .toList();

//     try {
//       // final response = await _aiService.getAiResponse(userText, history);
//       final response = await AiService.sendWithHistory(userText, history);
      
//       final aiMsg = MessageModel(
//         messageId: DateTime.now().toString(),
//         senderId: 'ai',
//         text: response,
//         timestamp: DateTime.now(),
//       );

//       setState(() {
//         _messages.insert(0, aiMsg);
//         _isTyping = false;
//       });
//     } catch (e) {
//       setState(() => _isTyping = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("AI Assistant encountered an error: $e")),
//         );
//       }
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             controller: _scrollController,
//             reverse: true,
//             padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
//             itemCount: _messages.length,
//             itemBuilder: (context, index) {
//               final m = _messages[index];
//               return MessageBubble(
//                 message: m,
//                 isMe: m.senderId == 'user',
//               );
//             },
//           ),
//         ),
//           if (_isTyping)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   SizedBox(width: 16),
//                   Text("AI is typing...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
//                 ],
//               ),
//             ),
//           _buildInput(),
//         ],
//       );
//   }

//   Widget _buildInput() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
//       color: Colors.white,
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF3F4F6),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: TextField(
//                 controller: _input,
//                 decoration: const InputDecoration(
//                   hintText: 'Ask anything...',
//                   border: InputBorder.none,
//                 ),
//                 onSubmitted: (_) => _handleSend(),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           GestureDetector(
//             onTap: _handleSend,
//             child: const CircleAvatar(
//               radius: 24,
//               backgroundColor: DeafTheme.orangeA,
//               child: Icon(Icons.send, color: Colors.white, size: 24),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/ai_service.dart';
import '../widgets/deaf_theme.dart';
import '../widgets/message_bubble.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _input = TextEditingController();
  final List<MessageModel> _messages = [];
  final AiService _aiService = AiService();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;

  void _handleSend() async {
    if (_input.text.trim().isEmpty) return;

    final userText = _input.text.trim();
    _input.clear();

    final userMsg = MessageModel(
      messageId: DateTime.now().toString(),
      senderId: 'user',
      text: userText,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMsg);
      _isTyping = true;
    });

    _scrollToBottom();

    /// ✅ FIXED HISTORY FORMAT
    final history = _messages
        .reversed
        .map((m) => {
              'role': m.senderId == 'user' ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    try {
      /// ✅ FIXED METHOD CALL
      final response =
          await _aiService.sendWithHistory(userText, history);

      final aiMsg = MessageModel(
        messageId: DateTime.now().toString(),
        senderId: 'ai',
        text: response,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, aiMsg);
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final m = _messages[index];
              return MessageBubble(
                message: m,
                isMe: m.senderId == 'user',
              );
            },
          ),
        ),

        if (_isTyping)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(width: 16),
                Text(
                  "AI is typing...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        _buildInput(),
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _input,
                decoration: const InputDecoration(
                  hintText: 'Ask anything...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _handleSend,
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: DeafTheme.orangeA,
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}