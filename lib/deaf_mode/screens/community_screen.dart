import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/community_controller.dart';
import '../services/community_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/community_models.dart';
import '../widgets/deaf_theme.dart';
import '../widgets/profile_barrier.dart';
import '../screens/room_chat_screen.dart';
import '../screens/story_viewer_screen.dart';
import '../screens/create_story_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late CommunityController _controller;
  final _currentUid = FirebaseAuth.instance.currentUser?.uid ?? "demo_user_123";

  @override
  void initState() {
    super.initState();
    _controller = CommunityController(CommunityService())..initialize();
  }

  void _createRoom(BuildContext context, UserModel? user) {
    ProfileBarrier.check(context, user, () {
      _showCreateRoomDialog(context, user!);
    });
  }

  void _joinRoom(BuildContext context, UserModel? user, RoomModel room) {
    ProfileBarrier.check(context, user, () async {
      if (!room.members.contains(user!.uid)) {
        await _controller.joinRoom(room.id, user.uid);
      }
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomChatScreen(room: room, user: user),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _currentUid.isEmpty ? Stream.value(null) : FirestoreService().streamUserProfile(_currentUid),
      builder: (context, userSnap) {
        final user = userSnap.data;
        
        return ChangeNotifierProvider.value(
          value: _controller,
          child: Consumer<CommunityController>(
            builder: (context, controller, child) {
              if (controller.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildStoriesSection(context, user, controller.stories),
                  const SizedBox(height: 12),
                  _buildCreateRoomButton(context, user),
                  const SizedBox(height: 12),
                  ...controller.rooms.map((r) => _buildRoomCard(context, user, r)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: DeafTheme.topGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Your Community',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildStoriesSection(BuildContext context, UserModel? user, List<StoryModel> stories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📸 Community Stories',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAddStoryButton(context, user),
              ...stories.map((s) => _buildStoryCircle(context, s)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddStoryButton(BuildContext context, UserModel? user) {
    return GestureDetector(
      onTap: () {
        ProfileBarrier.check(context, user, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreateStoryScreen(user: user!)));
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: DeafTheme.orangeA, width: 2),
                color: Colors.white,
              ),
              child: const Icon(Icons.add, color: DeafTheme.orangeA, size: 30),
            ),
            const SizedBox(height: 4),
            const Text('You', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCircle(BuildContext context, StoryModel story) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StoryViewerScreen(stories: _controller.stories, initialIndex: _controller.stories.indexOf(story))),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: DeafTheme.orangeA, width: 2),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: Text(story.userEmoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(height: 4),
            Text(
              story.userName.split(' ')[0],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRoomButton(BuildContext context, UserModel? user) {
    return GestureDetector(
      onTap: () => _createRoom(context, user),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: DeafTheme.topGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: const Text(
          'Create New Room',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, UserModel? user, RoomModel r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(r.emoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(r.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text('👥 ${r.totalMembers}  🟢 ${r.activeMembers} online', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _joinRoom(context, user, r),
            child: Container(
              decoration: BoxDecoration(
                gradient: DeafTheme.topGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Join',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedEmoji = '👥';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Room Name')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            const Text('Pick an emoji'),
            Wrap(
              children: ['👥', '🍔', '🎸', '💻', '🎨', '📚'].map((e) => GestureDetector(
                onTap: () => selectedEmoji = e,
                child: Padding(padding: const EdgeInsets.all(8.0), child: Text(e, style: const TextStyle(fontSize: 24))),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final room = RoomModel(
                  id: '',
                  name: nameController.text,
                  description: descController.text,
                  emoji: selectedEmoji,
                  createdBy: user.uid,
                  members: [user.uid],
                  totalMembers: 1,
                  createdAt: DateTime.now(),
                );
                await _controller.createRoom(room);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: DeafTheme.orangeA),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
