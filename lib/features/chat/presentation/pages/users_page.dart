import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New Chat',
          style: textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Users stream error: ${snapshot.error}');
            return const Center(child: Text('Error loading users'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No other users found', style: textTheme.titleLarge?.copyWith(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final String? photoUrl = user['photoUrl'];
              final String name = user['name'] ?? 'Unknown User';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                    child: photoUrl == null
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', 
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20))
                        : null,
                  ),
                  title: Text(name, style: textTheme.titleLarge?.copyWith(fontSize: 18)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(user['email'] ?? '', style: textTheme.bodyMedium),
                  ),
                  onTap: () async {
                    final chatRoomId = await _getOrCreateChatRoom(currentUserId!, user['id']);
                    if (context.mounted) {
                      context.replace('/chat/$chatRoomId');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _getOrCreateChatRoom(String currentUserId, String otherUserId) async {
    final firestore = FirebaseFirestore.instance;
    // Simple 1-on-1 chat room ID generation
    final ids = [currentUserId, otherUserId];
    ids.sort();
    final chatRoomId = ids.join('_');

    final chatDoc = await firestore.collection('chats').doc(chatRoomId).get();
    if (!chatDoc.exists) {
      await firestore.collection('chats').doc(chatRoomId).set({
        'participants': [currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }
}
