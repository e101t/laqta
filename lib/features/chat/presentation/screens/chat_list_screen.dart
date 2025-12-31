import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/models/chat_model.dart';
import 'package:luqta/core/models/user_model.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/app_text_field.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isLoading = true;
  final List<ChatPreview> _chats = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatPreview> get _filteredChats {
    if (_searchQuery.trim().isEmpty) return _chats;
    final query = _searchQuery.toLowerCase();
    return _chats
        .where(
          (chat) =>
              chat.userName.toLowerCase().contains(query) ||
              chat.lastMessage.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load chats where current user is a participant
      final chatsSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.uid)
          .orderBy('lastMessageAt', descending: true)
          .get();

      final chatPreviews = <ChatPreview>[];

      for (final chatDoc in chatsSnapshot.docs) {
        final chat = ChatModel.fromFirestore(chatDoc);

        // Get the other participant's ID
        final otherUserId = chat.participants.firstWhere(
          (id) => id != currentUser.uid,
          orElse: () => '',
        );
        if (otherUserId.isEmpty) {
          debugPrint('Chat ${chat.id} missing participant');
          continue;
        }

        // Load other user's data
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();

        if (!userDoc.exists) continue;

        final otherUser = UserModel.fromFirestore(userDoc);

        // Load last message
        final messagesSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat.id)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        String lastMessage = '';
        DateTime lastMessageTime = chat.lastMessageAt;
        int unreadCount = 0;

        if (messagesSnapshot.docs.isNotEmpty) {
          final lastMessageDoc = messagesSnapshot.docs.first;
          final message = MessageModel.fromFirestore(lastMessageDoc);
          lastMessage = message.content;
          lastMessageTime = message.createdAt;

          // Count unread messages (messages not seen by current user)
          final allMessagesSnapshot = await FirebaseFirestore.instance
              .collection('chats')
              .doc(chat.id)
              .collection('messages')
              .where('senderId', isNotEqualTo: currentUser.uid)
              .get();

          unreadCount = allMessagesSnapshot.docs
              .where(
                (doc) =>
                    !MessageModel.fromFirestore(doc).isSeenBy(currentUser.uid),
              )
              .length;
        }

        // Check if user is online (user is online if lastSeen is within last 5 minutes)
        final isOnline =
            otherUser.lastSeen != null &&
            DateTime.now().difference(otherUser.lastSeen!).inMinutes < 5;

        chatPreviews.add(
          ChatPreview(
            chatId: chat.id,
            userId: otherUser.uid,
            userName: otherUser.name,
            userImage: otherUser.photoUrl ?? '',
            lastMessage: lastMessage,
            timestamp: lastMessageTime,
            unreadCount: unreadCount,
            isOnline: isOnline,
          ),
        );
      }

      setState(() {
        _chats.clear();
        _chats.addAll(chatPreviews);
        _isLoading = false;
      });
    } catch (e) {
      // Handle error - for now, just set loading to false
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteChat(String chatId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete chat document from Firestore
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .delete();

        // Remove from local list
        setState(() {
          _chats.removeWhere((chat) => chat.chatId == chatId);
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete chat')),
          );
        }
      }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final chats = _filteredChats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(localizations.messages)),
      body: _isLoading
          ? const LoadingIndicator()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: AppSearchField(
                    controller: _searchController,
                    hintText: localizations.search,
                    enableSuggestions: false,
                    debounceDuration: const Duration(milliseconds: 250),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ),
                Expanded(
                  child: chats.isEmpty
                      ? Center(
                          child: EmptyState(
                            icon: Icons.chat_bubble_outline,
                            title: _chats.isEmpty
                                ? 'No Messages'
                                : 'No Results',
                            message: _chats.isEmpty
                                ? 'Start a conversation with a photographer'
                                : 'Try another name or keyword',
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadChats,
                          child: ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              final chat = chats[index];
                              return Dismissible(
                                key: Key(chat.chatId),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: AppColors.error,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _deleteChat(chat.chatId);
                                },
                                child: _ChatListItem(
                                  chat: chat,
                                  onTap: () {
                                    AppRouter.goToChat(
                                      context,
                                      chat.chatId,
                                      chat.userName,
                                    );
                                  },
                                  formatTimestamp: _formatTimestamp,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatPreview chat;
  final VoidCallback onTap;
  final String Function(DateTime) formatTimestamp;

  const _ChatListItem({
    required this.chat,
    required this.onTap,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.userName,
              style: AppTypography.h4.copyWith(
                fontWeight: chat.unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatTimestamp(chat.timestamp),
            style: AppTypography.caption.copyWith(
              color: chat.unreadCount > 0
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              style: AppTypography.bodySmall.copyWith(
                color: chat.unreadCount > 0
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: chat.unreadCount > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat.unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                chat.unreadCount.toString(),
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class ChatPreview {
  final String chatId;
  final String userId;
  final String userName;
  final String userImage;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;

  ChatPreview({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
  });
}
