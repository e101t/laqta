import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/models/comment_model.dart';
import 'package:luqta/core/models/reel_model.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  bool _isLoading = true;
  List<ReelModel> _reels = [];
  final Set<String> _likedReels = {};
  final Map<String, VideoPlayerController> _videoControllers = {};
  int _currentPage = 0;

  Future<void> _initializeVideoController(
    String reelId,
    String videoUrl,
  ) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoControllers[reelId] = controller;
    await controller.initialize();
    controller.setLooping(true);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all video controllers
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    super.dispose();
  }

  Future<void> _loadReels() async {
    setState(() => _isLoading = true);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reels')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _reels = snapshot.docs
            .map((doc) => ReelModel.fromFirestore(doc))
            .toList();
        _isLoading = false;
      });

      // Initialize first video if available
      if (_reels.isNotEmpty && _reels[0].videoUrl.isNotEmpty) {
        await _initializeVideoController(_reels[0].reelId, _reels[0].videoUrl);
        if (_videoControllers[_reels[0].reelId] != null) {
          await _videoControllers[_reels[0].reelId]?.play();
        }
      }
    } catch (e) {
      // Handle error - for now, keep empty list
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في تحميل الريلز. يرجى المحاولة مرة أخرى.'),
          ),
        );
      }
    }
  }

  void _toggleLike(ReelModel reel) async {
    final bool wasLiked = _likedReels.contains(reel.reelId);
    final int likeChange = wasLiked ? -1 : 1;

    setState(() {
      if (wasLiked) {
        _likedReels.remove(reel.reelId);
      } else {
        _likedReels.add(reel.reelId);
      }
      final index = _reels.indexOf(reel);
      _reels[index] = reel.copyWith(likes: reel.likes + likeChange);
    });

    try {
      await FirebaseFirestore.instance
          .collection('reels')
          .doc(reel.reelId)
          .update({'likes': FieldValue.increment(likeChange)});
    } catch (e) {
      // Revert local change on error
      setState(() {
        if (wasLiked) {
          _likedReels.add(reel.reelId);
        } else {
          _likedReels.remove(reel.reelId);
        }
        final index = _reels.indexOf(reel);
        _reels[index] = reel.copyWith(likes: reel.likes - likeChange);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في تحديث الإعجاب. يرجى المحاولة مرة أخرى.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_reels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: EmptyStates.noStories(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reels 🎬', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (index) async {
          setState(() => _currentPage = index);

          // Pause previous video
          if (_currentPage < _reels.length &&
              _videoControllers.containsKey(_reels[_currentPage].reelId)) {
            await _videoControllers[_reels[_currentPage].reelId]?.pause();
          }

          // Initialize and play new video if not already done
          final currentReel = _reels[index];
          if (currentReel.videoUrl.isNotEmpty &&
              !_videoControllers.containsKey(currentReel.reelId)) {
            await _initializeVideoController(
              currentReel.reelId,
              currentReel.videoUrl,
            );
          }
          if (_videoControllers[currentReel.reelId] != null) {
            await _videoControllers[currentReel.reelId]?.play();
          }
        },
        itemBuilder: (context, index) {
          return _ReelItem(
            reel: _reels[index],
            videoController: _videoControllers[_reels[index].reelId],
            isLiked: _likedReels.contains(_reels[index].reelId),
            onLike: () => _toggleLike(_reels[index]),
            onComment: () => _showComments(_reels[index]),
            onShare: () => _shareReel(_reels[index]),
            onProfileTap: () => _viewProfile(_reels[index]),
          );
        },
      ),
    );
  }

  void _showComments(ReelModel reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CommentsSheet(
        reel: reel,
        onCommentAdded: () => _updateReelCommentCount(reel),
      ),
    );
  }

  void _updateReelCommentCount(ReelModel reel) {
    setState(() {
      final index = _reels.indexOf(reel);
      if (index != -1) {
        _reels[index] = _reels[index].copyWith(
          comments: _reels[index].comments + 1,
        );
      }
    });
  }

  void _shareReel(ReelModel reel) async {
    try {
      // Update shares count in Firestore
      await FirebaseFirestore.instance
          .collection('reels')
          .doc(reel.reelId)
          .update({'shares': FieldValue.increment(1)});

      // Update local state
      final index = _reels.indexOf(reel);
      setState(() {
        _reels[index] = reel.copyWith(shares: reel.shares + 1);
      });

      // Implement actual sharing functionality using share_plus
      final String shareText =
          'Check out this reel by ${reel.photographerName}: ${reel.caption}';
      final String shareUrl = reel.videoUrl; // Assuming videoUrl is shareable

      await SharePlus.instance.share(
        ShareParams(
          text: '$shareText\n\n$shareUrl',
          subject: 'Reel by ${reel.photographerName}',
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم مشاركة الريل بنجاح!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في مشاركة الريل. يرجى المحاولة مرة أخرى.'),
          ),
        );
      }
    }
  }

  void _viewProfile(ReelModel reel) {
    AppRouter.goToPhotographerProfile(context, reel.photographerId);
  }
}

class _ReelItem extends StatelessWidget {
  final ReelModel reel;
  final VideoPlayerController? videoController;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onProfileTap;

  const _ReelItem({
    required this.reel,
    this.videoController,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        Container(
          color: Colors.black,
          child: videoController != null && videoController!.value.isInitialized
              ? VideoPlayer(videoController!)
              : reel.thumbnailUrl != null
              ? Image.network(
                  reel.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white54,
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
        ),

        // Gradient overlays
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 150,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              // Profile
              GestureDetector(
                onTap: onProfileTap,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: reel.photographerPhotoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      reel.photographerPhotoUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: reel.photographerPhotoUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        if (reel.isVerified)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Like
              _ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: reel.getLikesText(),
                color: isLiked ? Colors.red : Colors.white,
                onTap: onLike,
              ),
              const SizedBox(height: 20),

              // Comment
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${reel.comments}',
                onTap: onComment,
              ),
              const SizedBox(height: 20),

              // Share
              _ActionButton(
                icon: Icons.share,
                label: '${reel.shares}',
                onTap: onShare,
              ),
            ],
          ),
        ),

        // Bottom info
        Positioned(
          left: 16,
          right: 80,
          bottom: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photographer name
              GestureDetector(
                onTap: onProfileTap,
                child: Text(
                  '@${reel.photographerName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Caption
              Text(
                reel.caption,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Views
              Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reel.getViewsText()} مشاهدة',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final ReelModel reel;
  final VoidCallback? onCommentAdded;

  const _CommentsSheet({required this.reel, this.onCommentAdded});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('reelId', isEqualTo: widget.reel.reelId)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _comments = snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList();
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحميل التعليقات.')),
        );
      }
    }
  }

  void _handleSendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      // Get current user from Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب تسجيل الدخول لإضافة التعليقات.')),
          );
        }
        return;
      }

      // Fetch current user data from Firestore
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userSnapshot.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر العثور على بيانات المستخدم.')),
          );
        }
        return;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;
      final userName = userData['name'] ?? 'مستخدم غير معروف';
      final userPhotoUrl = userData['photoUrl'] as String?;

      final commentData = CommentModel(
        commentId: '',
        reelId: widget.reel.reelId,
        userId: currentUser.uid,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        text: text,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('comments')
          .add(commentData.toFirestore());

      // Update comment count in the reel
      await FirebaseFirestore.instance
          .collection('reels')
          .doc(widget.reel.reelId)
          .update({'comments': FieldValue.increment(1)});

      _commentController.clear();

      // Reload comments to show the new one
      await _loadComments();

      // Notify parent component
      widget.onCommentAdded?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة التعليق بنجاح!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في إضافة التعليق. يرجى المحاولة مرة أخرى.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التعليقات (${widget.reel.comments})',
                  style: AppTypography.h3,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoadingComments
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد تعليقات بعد. كن أول من يعلق!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      return _CommentItem(comment: _comments[index]);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.person, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _commentController,
                    hint: 'اكتب تعليق...',
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => _handleSendComment(),
                    decoration: InputDecoration(
                      hintText: '???? ?????...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _handleSendComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentModel comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: comment.userPhotoUrl != null
                ? NetworkImage(comment.userPhotoUrl!)
                : null,
            child: comment.userPhotoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: AppTypography.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  comment.getTimeAgo(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
