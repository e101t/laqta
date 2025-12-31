import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/models/notification_model.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/skeleton_loaders.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated';
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      setState(() {
        _notifications = notifications;
        _unreadCount = notifications.where((n) => !n.isRead).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load notifications: ${e.toString()}';
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.notificationId)
          .update({'isRead': true});

      setState(() {
        final index = _notifications.indexOf(notification);
        _notifications[index] = notification.copyWith(isRead: true);
        _unreadCount--;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to mark notification as read: ${e.toString()}';
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final batch = FirebaseFirestore.instance.batch();

      for (final notification in _notifications.where((n) => !n.isRead)) {
        batch.update(
          FirebaseFirestore.instance
              .collection('notifications')
              .doc(notification.notificationId),
          {'isRead': true},
        );
      }

      await batch.commit();

      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to mark all notifications as read: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.notificationId)
          .delete();

      setState(() {
        _notifications.remove(notification);
        if (!notification.isRead) _unreadCount--;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete notification: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(localizations.notifications),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('قراءة الكل'),
            ),
        ],
      ),
      body: _isLoading
          ? SkeletonList(
              itemBuilder: const _NotificationSkeleton(),
              itemCount: 6,
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadNotifications,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _notifications.isEmpty
          ? EmptyStates.noNotifications()
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () => _markAsRead(notification),
                    onDelete: () => _deleteNotification(notification),
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? AppColors.divider
                : AppColors.primary.withValues(alpha: 0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Text(
            notification.getIcon(),
            style: const TextStyle(fontSize: 32),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: AppTypography.h4.copyWith(
                    fontWeight: notification.isRead
                        ? FontWeight.w500
                        : FontWeight.bold,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: AppTypography.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                notification.getTimeAgo(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

// Notification skeleton loader
class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 40, height: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 200, height: 14),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    width: 80,
                    height: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
