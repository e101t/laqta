import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/screens/settings/report_screen.dart';
import 'package:luqta/core/models/chat_model.dart';

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
  final List<MessageModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .get();

      _messages.clear();
      _messages.addAll(
        messagesSnapshot.docs.map((doc) => MessageModel.fromFirestore(doc)),
      );
    } catch (e) {
      // Handle error - could show a snackbar or log
      debugPrint('Error loading messages: $e');
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get the other user's ID from the chat participants
    final chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    if (!chatDoc.exists) return;

    final chatData = chatDoc.data() as Map<String, dynamic>;
    final participants = List<String>.from(chatData['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUser.uid,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to determine user.')),
        );
      }
      return;
    }

    // Get current user's document
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) return;

    final userData = userDoc.data() as Map<String, dynamic>;
    final blockedUsers = List<String>.from(userData['blockedUsers'] ?? []);

    if (blockedUsers.contains(otherUserId)) {
      // User is already blocked, unblock them
      blockedUsers.remove(otherUserId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User unblocked')));
      }
    } else {
      // Block the user
      blockedUsers.add(otherUserId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User blocked')));
      }
    }

    // Update the user's blockedUsers list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'blockedUsers': blockedUsers});

    // Navigate back to chat list
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteChat() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      // Delete all messages in the chat
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat document
      batch.delete(
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId),
      );

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat deleted successfully')),
        );
        Navigator.of(context).pop(); // Go back to chat list
      }
    } catch (e) {
      debugPrint('Error deleting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete chat')));
      }
    }
  }

  void _reportUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get the other user's ID from the chat participants
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get()
        .then((chatDoc) {
          if (!chatDoc.exists) return;

          final chatData = chatDoc.data() as Map<String, dynamic>;
          final participants = List<String>.from(
            chatData['participants'] ?? [],
          );
          final otherUserId = participants.firstWhere(
            (id) => id != currentUser.uid,
            orElse: () => '',
          );

          if (otherUserId.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unable to determine user.')),
              );
            }
            return;
          }

          // Navigate to report screen
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
        });
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block User'),
            onTap: () {
              Navigator.pop(context);
              _blockUser();
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report User'),
            onTap: () {
              Navigator.pop(context);
              _reportUser();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Chat'),
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Send Image'),
            onTap: () {
              Navigator.pop(context);
              _sendImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_file),
            title: const Text('Send Video'),
            onTap: () {
              Navigator.pop(context);
              _sendVideo();
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('Send Document'),
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

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final message = MessageModel(
      id: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc()
          .id,
      chatId: widget.chatId,
      senderId: currentUser.uid,
      content: content,
      createdAt: DateTime.now(),
      type: 'text',
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toFirestore());

      // Update chat's lastMessageAt
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({'lastMessageAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      // Handle error - could show a snackbar or log
      debugPrint('Error sending message: $e');
      // Remove the message from UI if sending failed
      setState(() {
        _messages.remove(message);
      });
    }

    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Create a temporary message for UI feedback
    final tempMessage = MessageModel(
      id: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc()
          .id,
      chatId: widget.chatId,
      senderId: currentUser.uid,
      content: 'Uploading image...',
      createdAt: DateTime.now(),
      type: 'image',
    );

    setState(() {
      _messages.add(tempMessage);
    });

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(widget.chatId)
          .child('${tempMessage.id}.jpg');

      final file = File(pickedFile.path);
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update the message with the actual image URL
      final imageMessage = MessageModel(
        id: tempMessage.id,
        chatId: widget.chatId,
        senderId: currentUser.uid,
        content: downloadUrl,
        createdAt: DateTime.now(),
        type: 'image',
      );

      // Replace the temporary message
      setState(() {
        _messages.remove(tempMessage);
        _messages.add(imageMessage);
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(imageMessage.id)
          .set(imageMessage.toFirestore());

      // Update chat's lastMessageAt
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({'lastMessageAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      debugPrint('Error sending image: $e');
      // Remove the temporary message on error
      setState(() {
        _messages.remove(tempMessage);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send image')));
      }
    }

    _scrollToBottom();
  }

  Future<void> _sendVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Create a temporary message for UI feedback
    final tempMessage = MessageModel(
      id: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc()
          .id,
      chatId: widget.chatId,
      senderId: currentUser.uid,
      content: 'Uploading video...',
      createdAt: DateTime.now(),
      type: 'video',
    );

    setState(() {
      _messages.add(tempMessage);
    });

    try {
      // Upload video to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_videos')
          .child(widget.chatId)
          .child('${tempMessage.id}.mp4');

      final file = File(pickedFile.path);
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update the message with the actual video URL
      final videoMessage = MessageModel(
        id: tempMessage.id,
        chatId: widget.chatId,
        senderId: currentUser.uid,
        content: downloadUrl,
        createdAt: DateTime.now(),
        type: 'video',
      );

      // Replace the temporary message
      setState(() {
        _messages.remove(tempMessage);
        _messages.add(videoMessage);
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(videoMessage.id)
          .set(videoMessage.toFirestore());

      // Update chat's lastMessageAt
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({'lastMessageAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      debugPrint('Error sending video: $e');
      // Remove the temporary message on error
      setState(() {
        _messages.remove(tempMessage);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send video')));
      }
    }

    _scrollToBottom();
  }

  Future<void> _sendDocument() async {
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

    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Create a temporary message for UI feedback
    final tempMessage = MessageModel(
      id: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc()
          .id,
      chatId: widget.chatId,
      senderId: currentUser.uid,
      content: 'Uploading document...',
      createdAt: DateTime.now(),
      type: 'document',
    );

    setState(() {
      _messages.add(tempMessage);
    });

    try {
      // Upload document to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_documents')
          .child(widget.chatId)
          .child('${tempMessage.id}_${pickedFile.name}');

      final file = File(pickedFile.path!);
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update the message with the actual document URL and metadata
      final documentMessage = MessageModel(
        id: tempMessage.id,
        chatId: widget.chatId,
        senderId: currentUser.uid,
        content: '$downloadUrl|${pickedFile.name}|${pickedFile.size}',
        createdAt: DateTime.now(),
        type: 'document',
      );

      // Replace the temporary message
      setState(() {
        _messages.remove(tempMessage);
        _messages.add(documentMessage);
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(documentMessage.id)
          .set(documentMessage.toFirestore());

      // Update chat's lastMessageAt
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({'lastMessageAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      debugPrint('Error sending document: $e');
      // Remove the temporary message on error
      setState(() {
        _messages.remove(tempMessage);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send document')),
        );
      }
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUserName, style: AppTypography.h4),
                  Text(
                    'Online',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
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
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final isMe = message.senderId == currentUser?.uid;

                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
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
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == 'video') {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.message.content),
    );
    await _videoController!.initialize();
    if (mounted) setState(() {});
  }

  String _formatTime(DateTime createdAt) {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDocumentWidget(MessageModel message) {
    final parts = message.content.split('|');
    final url = parts[0];
    final fileName = parts.length > 1 ? parts[1] : 'Document';
    final fileSize = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;

    return InkWell(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Cannot open $fileName')));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isMe
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isMe
                ? Colors.white.withValues(alpha: 0.3)
                : AppColors.textSecondary.withValues(alpha: 0.3),
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
                    style: AppTypography.bodyMedium.copyWith(
                      color: widget.isMe ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileSize > 0) ...[
                    Text(
                      _formatFileSize(fileSize),
                      style: AppTypography.caption.copyWith(
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
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
                color: widget.isMe ? AppColors.primary : AppColors.surface,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.content,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(
                          width: 200,
                          height: 200,
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                  ] else if (widget.message.type == 'video') ...[
                    if (_videoController != null &&
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
                      const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ] else if (widget.message.type == 'document') ...[
                    _buildDocumentWidget(widget.message),
                  ] else ...[
                    Text(
                      widget.message.content,
                      style: AppTypography.bodyMedium.copyWith(
                        color: widget.isMe
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(widget.message.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: widget.isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
