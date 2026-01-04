import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/settings/domain/entities/report_submission.dart';
import 'package:luqta/features/settings/settings_dependencies.dart';

class ReportScreen extends StatefulWidget {
  final String? reportedUserId;
  final String? reportedUserName;
  final ReportType reportType;

  const ReportScreen({
    super.key,
    this.reportedUserId,
    this.reportedUserName,
    this.reportType = ReportType.user,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _detailsController = TextEditingController();

  String? _selectedReason;
  bool _isSubmitting = false;

  final List<ReportReason> _reportReasons = [
    ReportReason(
      id: 'inappropriate',
      icon: Icons.report,
      title: 'محتوى غير لائق',
      emoji: '⚠️',
    ),
    ReportReason(
      id: 'spam',
      icon: Icons.mail_outline,
      title: 'بريد مزعج',
      emoji: '📧',
    ),
    ReportReason(
      id: 'scam',
      icon: Icons.warning,
      title: 'احتيال أو نصب',
      emoji: '🚨',
    ),
    ReportReason(
      id: 'harassment',
      icon: Icons.block,
      title: 'تحرش أو مضايقة',
      emoji: '🚫',
    ),
    ReportReason(
      id: 'copyright',
      icon: Icons.copyright,
      title: 'انتهاك حقوق النشر',
      emoji: '©️',
    ),
    ReportReason(
      id: 'other',
      icon: Icons.more_horiz,
      title: 'أخرى',
      emoji: '📝',
    ),
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReason == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار سبب البلاغ')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final submission = ReportSubmission(
        reporterId: userId,
        reportedUserId: widget.reportedUserId,
        reportedUserName: widget.reportedUserName,
        reportType: widget.reportType.toString(),
        reason: _selectedReason!,
        details: _detailsController.text.trim(),
      );
      final result = await SettingsDependencies.submitReport().call(submission);
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to submit report',
        );
      }

      setState(() => _isSubmitting = false);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء إرسال البلاغ')),
      );
      return;
    }

    if (!mounted) return;

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تم إرسال البلاغ بنجاح',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'شكراً لك! سنقوم بمراجعة البلاغ في أقرب وقت.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CTAButton(
                text: 'تم',
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('إرسال بلاغ 🚨'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Warning Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error.withValues(alpha: 0.2),
                      AppColors.error.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.report_problem,
                  size: 50,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reported User Info
            if (widget.reportedUserName != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الإبلاغ عن:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            widget.reportedUserName!,
                            style: AppTypography.h4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Title
            Text('سبب البلاغ ⚠️', style: AppTypography.h3),
            const SizedBox(height: 16),

            // Report Reasons Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: _reportReasons.length,
              itemBuilder: (context, index) {
                final reason = _reportReasons[index];
                final isSelected = _selectedReason == reason.id;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedReason = reason.id);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.surface,
                      border: Border.all(
                        color: isSelected ? AppColors.error : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          reason.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reason.title,
                          style: AppTypography.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.error
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Details
            Text('تفاصيل إضافية 📋', style: AppTypography.h3),
            const SizedBox(height: 12),
            AppTextField(
              controller: _detailsController,
              hint: 'الرجاء وصف المشكلة بالتفصيل...',
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إضافة تفاصيل البلاغ';
                }
                if (value.trim().length < 20) {
                  return 'يجب أن تكون التفاصيل 20 حرف على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سيتم مراجعة بلاغك من قبل فريقنا خلال 24-48 ساعة. '
                      'نحن نأخذ جميع البلاغات على محمل الجد ونعمل على توفير بيئة آمنة للجميع.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            CTAButton(
              text: 'إرسال البلاغ ✅',
              onPressed: _submitReport,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ReportReason {
  final String id;
  final IconData icon;
  final String title;
  final String emoji;

  ReportReason({
    required this.id,
    required this.icon,
    required this.title,
    required this.emoji,
  });
}

enum ReportType { user, content, booking }
