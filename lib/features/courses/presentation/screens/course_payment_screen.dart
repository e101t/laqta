import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/courses/course_dependencies.dart';
import 'package:laqta/features/notifications/domain/entities/notification_model.dart';
import 'package:laqta/features/notifications/notifications_dependencies.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:logger/logger.dart';

/// Checkout screen for a course enrollment. A sibling of
/// lib/features/payment/presentation/screens/payment_screen.dart, kept
/// separate so the existing, already-audited booking payment flow is never
/// touched by the courses feature.
class CoursePaymentScreen extends StatefulWidget {
  final String enrollmentId;
  final double amount; // IQD
  final String courseTitle;
  final String photographerId;

  const CoursePaymentScreen({
    super.key,
    required this.enrollmentId,
    required this.amount,
    required this.courseTitle,
    required this.photographerId,
  });

  @override
  State<CoursePaymentScreen> createState() => _CoursePaymentScreenState();
}

class _CoursePaymentScreenState extends State<CoursePaymentScreen> {
  final Logger _logger = Logger(level: kDebugMode ? Level.debug : Level.off);
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (AppConstants.paymentsConfigured) {
      Stripe.publishableKey = AppConstants.stripePublishableKey;
    }
  }

  Future<void> _processPayment() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final intentResult = await CourseDependencies.createEnrollmentPaymentIntent()
          .call(
            enrollmentId: widget.enrollmentId,
            amount: widget.amount,
            currency: AppConstants.currencyIQD,
          );
      if (!mounted) return;
      if (!intentResult.isSuccess || intentResult.valueOrNull == null) {
        setState(() => _error = AppLocalizations.current.paymentStartFailed);
        return;
      }
      final intent = intentResult.valueOrNull!;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret,
          merchantDisplayName: 'Laqta',
          style: ThemeMode.dark,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return;

      final confirmResult = await CourseDependencies.confirmEnrollmentPayment()
          .call(
            enrollmentId: widget.enrollmentId,
            paymentIntentId: intent.paymentIntentId,
            amount: widget.amount,
          );
      if (!mounted) return;
      if (!confirmResult.isSuccess) {
        setState(() => _error = AppLocalizations.current.paymentConfirmFailed);
        return;
      }

      await _notifyPhotographer();
      if (!mounted) return;

      _showSuccess();
    } catch (e) {
      _logger.e('Course payment error: $e');
      if (mounted) setState(() => _error = AppLocalizations.current.paymentProcessError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _notifyPhotographer() async {
    if (widget.photographerId.isEmpty) return;
    try {
      final currentUserResult = await AuthDependencies.getCurrentUser()
          .call();
      final currentUserId = currentUserResult.valueOrNull?.id ?? '';
      String studentName = AppLocalizations.current.traineeFallback;
      if (currentUserId.isNotEmpty) {
        final profileResult = await ProfileDependencies.getUserProfile().call(
          userId: currentUserId,
        );
        studentName = profileResult.valueOrNull?.name ?? studentName;
      }
      final notification = NotificationModel(
        notificationId: '',
        userId: widget.photographerId,
        title: AppLocalizations.current.newEnrollmentTitle,
        body: AppLocalizations.current.newEnrollmentBody(studentName, widget.courseTitle),
        type: 'course',
        data: {'courseEnrollmentId': widget.enrollmentId},
        createdAt: DateTime.now(),
      );
      await NotificationsDependencies.createNotification().call(notification);
    } catch (_) {
      // Notifications are best-effort, matching booking_details_screen.dart.
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17191F),
        title: Text(
          AppLocalizations.current.paymentSuccessTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.current.enrolledInCourse(widget.courseTitle),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: Text(AppLocalizations.current.okAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.paymentsConfigured) {
      return Scaffold(
        backgroundColor: LaqtaColors.canvasDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  textDirection: TextDirection.ltr,
                  children: [LaqtaHeaderBackButton()],
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.current.paymentGatewayDisabled,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                textDirection: TextDirection.ltr,
                children: [LaqtaHeaderBackButton()],
              ),
              const SizedBox(height: 16),
              LaqtaLuxurySurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.courseTitle,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${widget.amount.toStringAsFixed(0)} IQD',
                      style: const TextStyle(
                        color: LaqtaColors.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFE24A3B)),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  LaqtaPrimaryAction(
                    label: _isLoading ? AppLocalizations.current.payingProgress : AppLocalizations.current.payNow,
                    onTap: _isLoading ? null : _processPayment,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
