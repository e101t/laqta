import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';

class PolicyTermsScreen extends StatelessWidget {
  final PolicyType type;

  const PolicyTermsScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          type == PolicyType.privacy
              ? 'سياسة الخصوصية ⚖️'
              : 'شروط الاستخدام 📄',
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                type == PolicyType.privacy ? Icons.security : Icons.description,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Last Updated
          Center(
            child: Text(
              'آخر تحديث: 15 نوفمبر 2024',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Content
          if (type == PolicyType.privacy)
            _buildPrivacyPolicy()
          else
            _buildTermsOfService(),

          const SizedBox(height: 32),

          // Contact Support
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.cta.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.support_agent,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'هل لديك استفسار؟',
                  style: AppTypography.h4.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text('تواصل معنا على:', style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.email,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'support@luqta.iq',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '📋 1. جمع المعلومات',
          'نقوم بجمع المعلومات التالية عند استخدامك للتطبيق:\n\n'
              '• الاسم الكامل واسم المستخدم\n'
              '• البريد الإلكتروني ورقم الهاتف\n'
              '• الموقع الجغرافي (المحافظة)\n'
              '• الصور والمحتوى الذي تقوم بتحميله\n'
              '• معلومات الاستخدام والتفاعل مع التطبيق',
        ),
        _buildSection(
          '🔒 2. حماية البيانات',
          'نلتزم بحماية بياناتك الشخصية من خلال:\n\n'
              '• تشفير جميع البيانات المرسلة والمستقبلة\n'
              '• استخدام Firebase الآمن لتخزين البيانات\n'
              '• عدم مشاركة معلوماتك مع أطراف ثالثة بدون إذنك\n'
              '• إمكانية حذف حسابك وبياناتك في أي وقت',
        ),
        _buildSection(
          '💳 3. معلومات الدفع',
          'نستخدم Stripe لمعالجة المدفوعات بشكل آمن. لا نقوم بتخزين تفاصيل بطاقتك الائتمانية على خوادمنا.',
        ),
        _buildSection(
          '📸 4. المحتوى المرفوع',
          'أنت المسؤول عن المحتوى الذي تقوم بتحميله. يجب أن يكون المحتوى:\n\n'
              '• قانونياً ولا ينتهك حقوق الآخرين\n'
              '• مناسباً وخالياً من المحتوى المسيء\n'
              '• يتوافق مع شروط الاستخدام',
        ),
        _buildSection(
          '🔔 5. الإشعارات',
          'نستخدم Firebase Cloud Messaging لإرسال الإشعارات. يمكنك إيقاف الإشعارات من الإعدادات.',
        ),
      ],
    );
  }

  Widget _buildTermsOfService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '✅ 1. الموافقة على الشروط',
          'باستخدامك لتطبيق لقطة، أنت توافق على جميع الشروط والأحكام المذكورة هنا. إذا كنت لا توافق على أي من هذه الشروط، يرجى عدم استخدام التطبيق.',
        ),
        _buildSection(
          '👥 2. أهلية الاستخدام',
          '• يجب أن تكون فوق 18 سنة لاستخدام التطبيق\n'
              '• يجب تقديم معلومات صحيحة ودقيقة\n'
              '• حساب واحد لكل مستخدم\n'
              '• مسؤولية حماية بيانات تسجيل الدخول الخاصة بك',
        ),
        _buildSection(
          '📸 3. الحجوزات والمدفوعات',
          '• جميع الحجوزات تخضع لموافقة المصور\n'
              '• الأسعار المعروضة هي أسعار ابتدائية وقد تتغير\n'
              '• سياسة الإلغاء تحددها اتفاقية الطرفين\n'
              '• المدفوعات آمنة عبر Stripe',
        ),
        _buildSection(
          '⚠️ 4. المحتوى المحظور',
          'يُحظر نشر أو تحميل:\n\n'
              '• محتوى مسيء أو غير قانوني\n'
              '• صور منتهكة لحقوق الملكية الفكرية\n'
              '• محتوى يحرض على العنف أو الكراهية\n'
              '• رسائل بريد مزعج أو احتيالية',
        ),
        _buildSection(
          '🛡️ 5. إخلاء المسؤولية',
          'تطبيق لقطة هو منصة وساطة بين الزبائن والمصورين. نحن لسنا مسؤولين عن:\n\n'
              '• جودة الخدمات المقدمة من المصورين\n'
              '• أي نزاعات بين الطرفين\n'
              '• المحتوى الذي يقوم المستخدمون بتحميله',
        ),
        _buildSection(
          '🔄 6. تعديل الشروط',
          'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إشعارك بأي تغييرات جوهرية.',
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h4.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              content,
              style: AppTypography.bodyMedium.copyWith(
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum PolicyType { privacy, terms }
