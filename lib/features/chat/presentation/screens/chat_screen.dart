import 'package:flutter/foundation.dart';
import 'package:laqta/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/core/widgets/backend_media_image.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/features/settings/presentation/screens/report_screen.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/chat/chat_dependencies.dart';
import 'package:laqta/features/chat/domain/entities/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final result = await AuthDependencies.getCurrentUser().call();
    if (!mounted) return;
    final currentUserId = result.valueOrNull?.id ?? '';
    setState(() {
      _currentUserId = currentUserId;
    });
    await _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    var hasError = false;
    try {
      final result = await ChatDependencies.getChatMessages().call(
        chatId: widget.chatId,
      );
      if (!result.isSuccess) {
        throw StateError('Failed to load messages');
      }
      _messages.clear();
      _messages.addAll(result.valueOrNull ?? []);
    } catch (e) {
      // Handle error - could show a snackbar or log
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error loading messages: $e');
      }
      hasError = true;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = hasError;
    });
    if (!hasError) {
      _scrollToBottom();
      _markMessagesAsRead();
    }
  }

  Future<void> _markMessagesAsRead() async {
    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty || _messages.isEmpty) {
      return;
    }

    final unreadIncomingIndexes = <int>[];
    for (var index = 0; index < _messages.length; index++) {
      final message = _messages[index];
      if (message.senderId != currentUserId &&
          !message.isSeenBy(currentUserId)) {
        unreadIncomingIndexes.add(index);
      }
    }

    if (unreadIncomingIndexes.isEmpty) {
      return;
    }

    final result = await ChatDependencies.markChatMessagesRead().call(
      chatId: widget.chatId,
      userId: currentUserId,
      messages: List<ChatMessage>.unmodifiable(_messages),
    );
    if (!result.isSuccess || !mounted) {
      return;
    }

    setState(() {
      for (final index in unreadIncomingIndexes) {
        final message = _messages[index];
        _messages[index] = message.copyWith(
          seenBy: {...message.seenBy, currentUserId}.toList(),
        );
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _blockUser() async {
    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;
    final localizations = AppLocalizations.of(context);

    try {
      final result = await ChatDependencies.toggleBlockUser().call(
        chatId: widget.chatId,
        currentUserId: currentUserId,
      );
      if (!result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.unableToDetermineUser)),
          );
        }
        return;
      }

      final isBlocked = result.valueOrNull ?? false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBlocked
                  ? localizations.userBlocked
                  : localizations.userUnblocked,
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error blocking user: $e');
      }
    }
  }

  Future<void> _deleteChat() async {
    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;
    final localizations = AppLocalizations.of(context);

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteChatTitle),
        content: Text(localizations.deleteChatPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              localizations.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (shouldDelete != true) return;

    try {
      final result = await ChatDependencies.deleteChatWithMessages().call(
        chatId: widget.chatId,
      );
      if (!result.isSuccess) {
        throw StateError('Delete chat failed');
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.chatDeleted)));
        Navigator.of(context).pop(); // Go back to chat list
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error deleting chat: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.chatDeleteFailed)));
      }
    }
  }

  Future<void> _reportUser() async {
    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;
    final localizations = AppLocalizations.of(context);

    final result = await ChatDependencies.getOtherParticipantId().call(
      chatId: widget.chatId,
      currentUserId: currentUserId,
    );
    if (!mounted) return;
    final otherUserId = result.valueOrNull;
    if (!result.isSuccess || otherUserId == null || otherUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.unableToDetermineUser)),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReportScreen(
            reportedUserId: otherUserId,
            reportedUserName: widget.otherUserName,
            reportType: ReportType.user,
          ),
        ),
      );
    }
  }

  void _showChatOptions() {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: Text(localizations.blockUser),
            onTap: () {
              Navigator.pop(context);
              _blockUser();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: Text(localizations.reportUser),
            onTap: () {
              Navigator.pop(context);
              _reportUser();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(localizations.deleteChatTitle),
            onTap: () {
              Navigator.pop(context);
              _deleteChat();
            },
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: Text(localizations.sendImage),
            onTap: () {
              Navigator.pop(context);
              _sendImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_file),
            title: Text(localizations.sendVideo),
            onTap: () {
              Navigator.pop(context);
              _sendVideo();
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(localizations.sendDocument),
            onTap: () {
              Navigator.pop(context);
              _sendDocument();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;

    final messageId = ChatDependencies.generateMessageId().call(
      chatId: widget.chatId,
    );
    final message = ChatMessage(
      id: messageId,
      chatId: widget.chatId,
      senderId: currentUserId,
      content: content,
      createdAt: DateTime.now(),
      type: 'text',
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    try {
      final result = await ChatDependencies.sendChatMessage().call(message);
      if (!result.isSuccess) {
        throw StateError('Send message failed');
      }
    } catch (e) {
      // Handle error - could show a snackbar or log
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error sending message: $e');
      }
      // Remove the message from UI if sending failed
      if (mounted) {
        setState(() {
          _messages.remove(message);
        });
      }
    }

    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final localizations = AppLocalizations.of(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;

    if (pickedFile == null) return;

    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;

    // Create a temporary message for UI feedback
    final messageId = ChatDependencies.generateMessageId().call(
      chatId: widget.chatId,
    );
    final tempMessage = ChatMessage(
      id: messageId,
      chatId: widget.chatId,
      senderId: currentUserId,
      content: localizations.uploadingImage,
      createdAt: DateTime.now(),
      type: 'image',
    );

    setState(() {
      _messages.add(tempMessage);
    });

    try {
      final result = await ChatDependencies.sendChatMediaMessage().call(
        chatId: widget.chatId,
        senderId: currentUserId,
        type: 'image',
        filePath: pickedFile.path,
        messageId: messageId,
      );
      if (!mounted) return;
      final imageMessage = result.valueOrNull;
      if (!result.isSuccess || imageMessage == null) {
        throw StateError('Send image failed');
      }

      setState(() {
        _messages.remove(tempMessage);
        _messages.add(imageMessage);
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error sending image: $e');
      }
      // Remove the temporary message on error
      if (mounted) {
        setState(() {
          _messages.remove(tempMessage);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.sendImageFailed)));
      }
    }

    _scrollToBottom();
  }

  Future<void> _sendVideo() async {
    final localizations = AppLocalizations.of(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (!mounted) return;

    if (pickedFile == null) return;

    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;

    // Create a temporary message for UI feedback
    final messageId = ChatDependencies.generateMessageId().call(
      chatId: widget.chatId,
    );
    final tempMessage = ChatMessage(
      id: messageId,
      chatId: widget.chatId,
      senderId: currentUserId,
      content: localizations.uploadingVideo,
      createdAt: DateTime.now(),
      type: 'video',
    );

    setState(() {
      _messages.add(tempMessage);
    });

    try {
      final result = await ChatDependencies.sendChatMediaMessage().call(
        chatId: widget.chatId,
        senderId: currentUserId,
        type: 'video',
        filePath: pickedFile.path,
        messageId: messageId,
      );
      if (!mounted) return;
      final videoMessage = result.valueOrNull;
      if (!result.isSuccess || videoMessage == null) {
        throw StateError('Send video failed');
      }

      setState(() {
        _messages.remove(tempMessage);
        _messages.add(videoMessage);
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error sending video: $e');
      }
      // Remove the temporary message on error
      if (mounted) {
        setState(() {
          _messages.remove(tempMessage);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.sendVideoFailed)));
      }
    }

    _scrollToBottom();
  }

  Future<void> _sendDocument() async {
    final localizations = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
      ],
    );
    if (!mounted) return;

    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) return;
    if (pickedFile.path == null) return;

    // Create a temporary message for UI feedback
    final messageId = ChatDependencies.generateMessageId().call(
      chatId: widget.chatId,
    );
    final tempMessage = ChatMessage(
      id: messageId,
      chatId: widget.chatId,
      senderId: currentUserId,
      content: localizations.uploadingDocument,
      createdAt: DateTime.now(),
      type: 'document',
    );

    setState(() {
      _messages.add(tempMessage);
    });

    try {
      final result = await ChatDependencies.sendChatMediaMessage().call(
        chatId: widget.chatId,
        senderId: currentUserId,
        type: 'document',
        filePath: pickedFile.path!,
        messageId: messageId,
        fileName: pickedFile.name,
        fileSize: pickedFile.size,
      );
      if (!mounted) return;
      final documentMessage = result.valueOrNull;
      if (!result.isSuccess || documentMessage == null) {
        throw StateError('Send document failed');
      }

      setState(() {
        _messages.remove(tempMessage);
        _messages.add(documentMessage);
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error sending document: $e');
      }
      // Remove the temporary message on error
      if (mounted) {
        setState(() {
          _messages.remove(tempMessage);
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.sendDocumentFailed)),
        );
      }
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUserName, style: textTheme.titleMedium),
                  Text(
                    localizations.onlineNow,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? EmptyStates.error(onRetry: _loadMessages)
                : _messages.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: localizations.noMessagesYet,
                    message: localizations.startConversationPrompt,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == _currentUserId;

                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      _showAttachmentOptions();
                    },
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: _messageController,
                      hint: localizations.typeMessage,
                      maxLines: null,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: localizations.typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  final BackendMediaService _mediaService = BackendMediaService();
  VideoPlayerController? _videoController;
  bool _isPreparingVideo = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.type == widget.message.type &&
        oldWidget.message.content == widget.message.content &&
        oldWidget.message.mediaId == widget.message.mediaId) {
      return;
    }

    if (widget.message.type == 'video') {
      _videoController?.dispose();
      _videoController = null;
      setState(() {
        _isPreparingVideo = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    if (_isPreparingVideo || _videoController != null) {
      return;
    }
    final sourceUrl = _resolveMediaSource(widget.message);
    if (sourceUrl == null) {
      return;
    }

    try {
      setState(() {
        _isPreparingVideo = true;
      });
      final resolvedUrl = await _mediaService.resolveDisplayUrl(sourceUrl);
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(resolvedUrl),
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController?.dispose();
        _videoController = controller;
        _isPreparingVideo = false;
      });
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error preparing video message: $e');
      }
      if (mounted) {
        setState(() {
          _isPreparingVideo = false;
        });
      }
    }
  }

  String? _resolveMediaSource(ChatMessage message) {
    if (message.mediaId != null && message.mediaId!.trim().isNotEmpty) {
      return BackendMediaService.mediaApiUrlFromId(message.mediaId!);
    }

    final content = message.content;
    if (content.trim().isEmpty) {
      return null;
    }
    if (message.type == 'document') {
      return content.split('|').first.trim();
    }
    return content.trim();
  }

  bool _looksLikeUrl(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(normalized);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  String _formatTime(DateTime createdAt) {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDocumentWidget(ChatMessage message) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final parts = message.content.split('|');
    final url = _resolveMediaSource(message) ?? '';
    final fileName =
        message.fileName ?? (parts.length > 1 ? parts[1] : 'Document');
    final fileSize =
        message.fileSize ??
        (parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0);

    return InkWell(
      onTap: () async {
        try {
          final resolvedUrl = await _mediaService.resolveDisplayUrl(url);
          final uri = Uri.parse(resolvedUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return;
          }
        } catch (e) {
          if (kDebugMode) {
            AppLogger.d('runtime', 'Error opening document message: $e');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.cannotOpenFile} $fileName'),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isMe
              ? Colors.white.withValues(alpha: 0.1)
              : scheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isMe
                ? Colors.white.withValues(alpha: 0.3)
                : scheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: widget.isMe ? Colors.white : scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileSize > 0) ...[
                    Text(
                      _formatFileSize(fileSize),
                      style: textTheme.labelSmall?.copyWith(
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    const SizedBox.shrink(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: widget.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.isMe) ...[
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isMe ? scheme.primary : scheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
                  bottomRight: Radius.circular(widget.isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.type == 'image') ...[
                    if (_looksLikeUrl(_resolveMediaSource(widget.message)))
                      BackendMediaImage(
                        url: _resolveMediaSource(widget.message)!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                      )
                    else
                      Text(
                        widget.message.content,
                        style: textTheme.bodyMedium?.copyWith(
                          color: widget.isMe ? Colors.white : scheme.onSurface,
                        ),
                      ),
                  ] else if (widget.message.type == 'video') ...[
                    if (!_looksLikeUrl(
                      _resolveMediaSource(widget.message),
                    )) ...[
                      Text(
                        widget.message.content.isNotEmpty
                            ? widget.message.content
                            : 'Video',
                        style: textTheme.bodyMedium?.copyWith(
                          color: widget.isMe ? Colors.white : scheme.onSurface,
                        ),
                      ),
                    ] else if (_videoController != null &&
                        _videoController!.value.isInitialized) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                      ),
                    ] else ...[
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: _isPreparingVideo
                              ? const CircularProgressIndicator()
                              : IconButton.filled(
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  onPressed: _initializeVideoPlayer,
                                ),
                        ),
                      ),
                    ],
                  ] else if (widget.message.type == 'document') ...[
                    if (_looksLikeUrl(_resolveMediaSource(widget.message)))
                      _buildDocumentWidget(widget.message)
                    else
                      Text(
                        widget.message.fileName ??
                            (widget.message.content.isNotEmpty
                                ? widget.message.content
                                : 'Document'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: widget.isMe ? Colors.white : scheme.onSurface,
                        ),
                      ),
                  ] else ...[
                    Text(
                      widget.message.content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: widget.isMe ? Colors.white : scheme.onSurface,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(widget.message.createdAt),
                    style: textTheme.labelSmall?.copyWith(
                      color: widget.isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primary,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
