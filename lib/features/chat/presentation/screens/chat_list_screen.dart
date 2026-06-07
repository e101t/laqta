import 'package:flutter/material.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/chat/chat_dependencies.dart';
import 'package:laqta/features/chat/domain/entities/chat_thread_preview.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = const [
    'الكل',
    'المصورون',
    'القاعات',
    'الترتيبات',
  ];
  String _selectedFilter = 'الكل';
  String _search = '';
  bool _isLoading = true;
  String? _errorMessage;
  List<ChatThreadPreview> _conversations = const [];

  List<ChatThreadPreview> get _visibleConversations {
    final filtered = _conversations.where(_matchesSelectedFilter).toList();
    final query = _search.trim();
    if (query.isEmpty) {
      return filtered;
    }
    return filtered
        .where(
          (conversation) =>
              conversation.userName.contains(query) ||
              conversation.lastMessage.contains(query),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw StateError('Missing current user');
      }

      final result = await ChatDependencies.getChatThreads().call(
        userId: userId,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load chats',
        );
      }

      if (!mounted) return;
      setState(() {
        _conversations = result.valueOrNull ?? const [];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _conversations = const [];
        _isLoading = false;
        _errorMessage = 'تعذر تحميل الرسائل';
      });
    }
  }

  bool _matchesSelectedFilter(ChatThreadPreview conversation) {
    if (_selectedFilter == 'الكل') return true;
    final name = conversation.userName.toLowerCase();
    final message = conversation.lastMessage.toLowerCase();
    if (_selectedFilter == 'القاعات') {
      return name.contains('قاعة') ||
          name.contains('hall') ||
          name.contains('venue');
    }
    if (_selectedFilter == 'الترتيبات') {
      return message.contains('حجز') ||
          message.contains('طلب') ||
          message.contains('booking') ||
          message.contains('request');
    }
    if (_selectedFilter == 'المصورون') {
      return !name.contains('قاعة') &&
          !name.contains('hall') &&
          !name.contains('venue');
    }
    return true;
  }

  String _displayName(ChatThreadPreview conversation) {
    final name = conversation.userName.trim();
    return name.isEmpty ? 'محادثة' : name;
  }

  String _lastMessage(ChatThreadPreview conversation) {
    final message = conversation.lastMessage.trim();
    return message.isEmpty ? 'لا توجد رسائل بعد' : message;
  }

  String _timeLabel(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays >= 1) {
      return 'أمس';
    }
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final suffix = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  ImageProvider? _avatarProvider(ChatThreadPreview conversation) {
    final image = conversation.userImage.trim();
    final uri = Uri.tryParse(image);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return NetworkImage(image);
    }
    return null;
  }

  Widget _buildConversationRow(ChatThreadPreview chat) {
    final avatar = _avatarProvider(chat);
    return Column(
      children: [
        InkWell(
          onTap: () =>
              AppRouter.goToChat(context, chat.chatId, _displayName(chat)),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: avatar,
                  child: avatar == null
                      ? const Icon(Icons.person, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName(chat),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _lastMessage(chat),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _timeLabel(chat.timestamp),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (chat.unreadCount > 0)
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: LaqtaColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(color: Color(0xFF1D2027), height: 1),
      ],
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadConversations,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final visible = _visibleConversations;
    if (visible.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            'لا توجد محادثات بعد',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
      );
    }

    return Column(children: visible.map(_buildConversationRow).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1014),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          children: [
            Row(
              textDirection: TextDirection.ltr,
              children: [
                const LaqtaTopIconButton(icon: Icons.search_rounded),
                const Spacer(),
                Text(
                  'الرسائل',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const LaqtaTopIconButton(icon: Icons.edit_outlined),
              ],
            ),
            SizedBox(
              height: 0,
              child: Opacity(
                opacity: 0,
                child: IgnorePointer(
                  child: LaqtaLuxurySearchBar(
                    hint: 'ابحث في الرسائل',
                    controller: _searchController,
                    readOnly: false,
                    onChanged: (value) => setState(() => _search = value),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    return LaqtaFilterPill(
                      label: filter,
                      selected: filter == _selectedFilter,
                      onTap: () => setState(() => _selectedFilter = filter),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildBodyContent(),
          ],
        ),
      ),
    );
  }
}
