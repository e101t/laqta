import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/services/notification_navigation_service.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/skeleton_loaders.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/notifications/domain/entities/notification_model.dart';
import 'package:luqta/features/notifications/notifications_dependencies.dart';

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
      final userResult = await AuthDependencies.getCurrentUser().call();
      if (!mounted) return;
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context).userNotAuthenticated;
        });
        return;
      }

      final result = await NotificationsDependencies.getNotifications().call(
        userId: userId,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ??
              AppLocalizations.of(context).loadNotificationsFailed,
        );
      }
      final notifications = result.valueOrNull ?? <NotificationModel>[];

      setState(() {
        _notifications = notifications;
        _unreadCount = notifications.where((n) => !n.isRead).length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).loadNotificationsFailed;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final result = await NotificationsDependencies.markNotificationRead()
          .call(notification.notificationId);
      if (!mounted) return;
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ??
              AppLocalizations.of(context).markNotificationReadFailed,
        );
      }

      setState(() {
        final index = _notifications.indexOf(notification);
        _notifications[index] = notification.copyWith(isRead: true);
        _unreadCount--;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context).markNotificationReadFailed;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      if (!mounted) return;
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) return;

      final unreadIds = _notifications
          .where((notification) => !notification.isRead)
          .map((notification) => notification.notificationId)
          .toList();
      final result = await NotificationsDependencies.markAllNotificationsRead()
          .call(userId: userId, notificationIds: unreadIds);
      if (!mounted) return;
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ??
              AppLocalizations.of(context).markAllNotificationsReadFailed,
        );
      }

      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        ).markAllNotificationsReadFailed;
      });
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      final result = await NotificationsDependencies.deleteNotification().call(
        notification.notificationId,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ??
              AppLocalizations.of(context).deleteNotificationFailed,
        );
      }

      setState(() {
        _notifications.remove(notification);
        if (!notification.isRead) _unreadCount--;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context).deleteNotificationFailed;
      });
    }
  }

  Future<void> _openNotification(NotificationModel notification) async {
    await _markAsRead(notification);
    if (!mounted) return;
    NotificationNavigationService.instance.openNotificationModel(notification);
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
            Text(localizations.notifications),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.error,
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
              child: Text(localizations.readAllNotifications),
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
                    Icon(Icons.error_outline, size: 48, color: scheme.error),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadNotifications,
                      child: Text(localizations.retry),
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
                    onTap: () => _openNotification(notification),
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: scheme.error,
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
              ? scheme.surface
              : scheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? scheme.outlineVariant
                : scheme.primary.withValues(alpha: 0.3),
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
                  style: textTheme.titleMedium?.copyWith(
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
                  decoration: BoxDecoration(
                    color: scheme.primary,
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
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                notification.getTimeAgo(),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
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
