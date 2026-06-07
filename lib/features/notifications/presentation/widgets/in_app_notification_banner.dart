import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/services/notification_navigation_service.dart';
import 'package:laqta/features/notifications/data/fcm_service.dart';

class InAppNotificationBannerHost extends StatefulWidget {
  const InAppNotificationBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<InAppNotificationBannerHost> createState() =>
      _InAppNotificationBannerHostState();
}

class _InAppNotificationBannerHostState
    extends State<InAppNotificationBannerHost> {
  RemoteMessage? _message;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    FcmService.instance.foregroundMessage.addListener(_onMessage);
  }

  @override
  void dispose() {
    _timer?.cancel();
    FcmService.instance.foregroundMessage.removeListener(_onMessage);
    super.dispose();
  }

  void _onMessage() {
    final message = FcmService.instance.foregroundMessage.value;
    if (message == null || !mounted) return;
    _timer?.cancel();
    setState(() => _message = message);
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _open() {
    final message = _message;
    if (message == null) return;
    setState(() => _message = null);
    NotificationNavigationService.instance.openRemoteMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        PositionedDirectional(
          top: 0,
          start: 0,
          end: 0,
          child: SafeArea(
            bottom: false,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              offset: _message == null ? const Offset(0, -1.2) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _message == null ? 0 : 1,
                child: _Banner(message: _message, onTap: _open),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message, required this.onTap});

  final RemoteMessage? message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = message?.notification?.title ?? 'LAQTA';
    final body = message?.notification?.body ?? _fallbackBody(message?.data);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Material(
          color: const Color(0xFF11151B),
          elevation: 10,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFF0B85A),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFD7D7D7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fallbackBody(Map<String, dynamic>? data) {
    if (data == null) return '';
    return (data['body'] as String?) ?? (data['message'] as String?) ?? '';
  }
}
