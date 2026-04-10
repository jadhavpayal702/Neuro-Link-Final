import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_controller.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';
import '../widgets/deaf_theme.dart';
import '../widgets/user_card.dart';
import 'chat_screen.dart';

class UserDiscoveryScreen extends StatefulWidget {
  final String currentUid;

  const UserDiscoveryScreen({super.key, required this.currentUid});

  @override
  State<UserDiscoveryScreen> createState() => _UserDiscoveryScreenState();
}

class _UserDiscoveryScreenState extends State<UserDiscoveryScreen> {
  late final ChatController _controller;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController(FirestoreService(), ChatService(), widget.currentUid);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextField(
            controller: _search,
            onChanged: (v) => _controller.filterUsers(v),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search, color: DeafTheme.orangeA),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _controller.streamUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: DeafTheme.orangeA));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No other users found.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // Update controller with new list for filtering
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _controller.updateDiscoveredUsers(users);
                });

                return Consumer<ChatController>(
                  builder: (context, controller, _) {
                    final filtered = controller.filteredUsers;
                    if (filtered.isEmpty && _search.text.isNotEmpty) {
                      return const Center(child: Text("No users match your search."));
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        return UserCard(
                          user: user,
                          onTap: () async {
                            final chatId = await controller.startChat(user.uid);
                            if (mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatId: chatId,
                                    currentUserUid: widget.currentUid,
                                    otherUser: user,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
  }
}
