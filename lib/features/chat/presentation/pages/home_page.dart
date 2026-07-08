import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        title: Text(
          'Messages',
          style: textTheme.displayLarge?.copyWith(fontSize: 28, letterSpacing: -1),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, size: 20),
            ),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/');
          }
        },
        child: currentUserId == null 
            ? const Center(child: CircularProgressIndicator()) 
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participants', arrayContains: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint('Chats stream error: ${snapshot.error}');
                    return const Center(child: Text('Error loading chats'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Sort locally to avoid requiring a composite index in Firestore
                  final chats = snapshot.data!.docs.toList();
                  chats.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = (aData['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                    final bTime = (bData['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now();
                    return bTime.compareTo(aTime);
                  });

                  if (chats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No messages yet', style: textTheme.titleLarge?.copyWith(color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          Text('Tap the button below to start a chat', style: textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: chats.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final chatData = chats[index].data() as Map<String, dynamic>;
                      final chatId = chats[index].id;
                      final participants = List<String>.from(chatData['participants'] ?? []);
                      final otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
                      
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return const SizedBox();
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                          final name = userData['name'] ?? 'Unknown User';
                          final photoUrl = userData['photoUrl'];
                          
                          // Time formatting
                          final time = (chatData['lastMessageTime'] as Timestamp?)?.toDate();
                          final timeString = time != null 
                              ? "${time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}"
                              : "";
                          
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
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(name, style: textTheme.titleLarge?.copyWith(fontSize: 18)),
                                  ),
                                  Text(timeString, style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  chatData['lastMessage'] ?? 'Started a chat',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              onTap: () {
                                context.push('/chat/$chatId');
                              },
                            ),
                          );
                        }
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/users');
        },
        backgroundColor: colorScheme.primary,
        elevation: 4,
        icon: const Icon(Icons.edit_square, color: Colors.white),
        label: const Text('New Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
