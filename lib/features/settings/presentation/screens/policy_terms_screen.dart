import 'package:flutter/material.dart';

enum PolicyType { privacy, terms, deleteAccount, content }

class PolicyTermsScreen extends StatelessWidget {
  final PolicyType type;

  const PolicyTermsScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = switch (type) {
      PolicyType.privacy => isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
      PolicyType.terms => isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
      PolicyType.deleteAccount =>
        isArabic ? 'سياسة حذف الحساب' : 'Delete Account Policy',
      PolicyType.content => isArabic ? 'سياسة المحتوى' : 'Content Policy',
    };
    final lastUpdated = isArabic
        ? 'آخر تحديث: 26 يناير 2026'
        : 'Last updated: January 26, 2026';
    final supportTitle = isArabic ? 'هل تحتاج مساعدة؟' : 'Need help?';
    final supportText = isArabic ? 'تواصل مع فريق الدعم:' : 'Contact support:';

    final sections = switch (type) {
      PolicyType.privacy => _privacySections(isArabic),
      PolicyType.terms => _termsSections(isArabic),
      PolicyType.deleteAccount => _deleteAccountSections(isArabic),
      PolicyType.content => _contentSections(isArabic),
    };

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                type == PolicyType.privacy ? Icons.security : Icons.description,
                size: 40,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              lastUpdated,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
          for (final section in sections)
            _buildSection(context, section.title, section.body),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.10),
                  scheme.secondary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.30)),
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent, size: 40, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  supportTitle,
                  style: textTheme.titleMedium?.copyWith(color: scheme.primary),
                ),
                const SizedBox(height: 8),
                Text(supportText, style: textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email, size: 16, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'support@laqta.cloud',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
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

  List<_PolicySection> _privacySections(bool isArabic) {
    if (isArabic) {
      return const [
        _PolicySection(
          '1) البيانات التي نجمعها',
          'نجمع معلومات الحساب مثل الاسم ورقم الهاتف والمدينة، ومعلومات الملف للمصورين، ورسائل وتفاصيل الحجوزات وملفات التسليم داخل المنصة.',
        ),
        _PolicySection(
          '2) كيف نستخدم بياناتك',
          'نستخدم البيانات لتشغيل المنصة ومطابقة الطلبات، وتحسين الجودة، وإدارة النزاعات، وإرسال الإشعارات الضرورية.',
        ),
        _PolicySection(
          '3) مشاركة البيانات',
          'لا نبيع بياناتك. قد نشارك البيانات داخل الحجز بين العميل والمصور، أو مع الجهات الرسمية عند الطلب القانوني.',
        ),
        _PolicySection(
          '4) الاحتفاظ والحذف',
          'يمكنك طلب حذف حسابك. قد نحتفظ ببعض السجلات لمدة محدودة للامتثال أو حل النزاعات.',
        ),
        _PolicySection(
          '5) الأمان',
          'نطبق إجراءات حماية معقولة، ولكن لا يمكن ضمان الأمان الكامل لأي خدمة رقمية.',
        ),
      ];
    }

    return const [
      _PolicySection(
        '1) Data we collect',
        'We collect account details (name, phone, city), photographer profile data, messages, booking details, and delivery files shared inside the platform.',
      ),
      _PolicySection(
        '2) How we use data',
        'We use data to operate the platform, match requests with photographers, improve quality, manage disputes, and send essential notifications.',
      ),
      _PolicySection(
        '3) Data sharing',
        'We do not sell your data. We may share data within a booking between client and photographer, or with authorities when legally required.',
      ),
      _PolicySection(
        '4) Retention & deletion',
        'You can request account deletion. We may retain certain records for a limited period for compliance or dispute resolution.',
      ),
      _PolicySection(
        '5) Security',
        'We apply reasonable protections, but no digital service can guarantee absolute security.',
      ),
    ];
  }

  List<_PolicySection> _termsSections(bool isArabic) {
    if (isArabic) {
      return const [
        _PolicySection(
          '1) طبيعة الخدمة',
          'لقطة منصة تشغيل وضمان لخدمة التصوير، وليست جهة توظيف مباشر للمصورين.',
        ),
        _PolicySection(
          '2) الحساب والمسؤولية',
          'يلتزم المستخدم بتقديم معلومات صحيحة والالتزام بسياسات المنصة وعدم مشاركة وسائل الاتصال قبل تأكيد الحجز.',
        ),
        _PolicySection(
          '3) الطلبات والعروض',
          'الطلب يصبح ملزمًا بعد قبول عرض، والعروض صالحة لفترة محددة قبل الإغلاق.',
        ),
        _PolicySection(
          '4) التسليم والتعديل',
          'التسليم يتم داخل المنصة. يحق للعميل طلب تعديل واحد مجاني ضمن نطاق الطلب؛ الأعمال الإضافية تتطلب عرضًا جديدًا.',
        ),
        _PolicySection(
          '5) الإلغاء والنزاعات',
          'الإلغاء يؤثر على مؤشرات الثقة. النزاعات تُفتح داخل الحجز فقط ويتم حسمها بقرار الإدارة.',
        ),
        _PolicySection(
          '6) الدفع',
          'الدفع غير مفعّل في هذه النسخة. عند تفعيل الدفع سيتم نشر سياسة منفصلة.',
        ),
      ];
    }

    return const [
      _PolicySection(
        '1) Service nature',
        'Laqta is an operations and guarantee platform for photography services; it does not employ photographers directly.',
      ),
      _PolicySection(
        '2) Accounts & responsibility',
        'Users must provide accurate information, follow platform policies, and avoid sharing contact details before a booking is confirmed.',
      ),
      _PolicySection(
        '3) Requests & offers',
        'A request becomes binding after an offer is accepted. Offers are valid for a limited period before closing.',
      ),
      _PolicySection(
        '4) Delivery & revisions',
        'Delivery happens inside the platform. Clients are entitled to one free revision within the original scope; additional work requires a new offer.',
      ),
      _PolicySection(
        '5) Cancellations & disputes',
        'Cancellations impact trust indicators. Disputes are opened inside the booking and resolved by admin decision.',
      ),
      _PolicySection(
        '6) Payments',
        'Payments are not enabled in this version. A separate policy will be published once activated.',
      ),
    ];
  }

  List<_PolicySection> _deleteAccountSections(bool isArabic) {
    if (isArabic) {
      return const [
        _PolicySection(
          '1) طريقة طلب الحذف',
          'يمكنك طلب حذف الحساب من الإعدادات أو عبر التواصل مع الدعم على support@laqta.cloud.',
        ),
        _PolicySection(
          '2) ما يتم حذفه',
          'نحذف بيانات الحساب والملف الشخصي والمحتوى غير المطلوب للاحتفاظ التشغيلي أو القانوني.',
        ),
        _PolicySection(
          '3) ما قد نحتفظ به مؤقتًا',
          'قد نحتفظ بسجلات محدودة متعلقة بالأمان، النزاعات، أو الالتزامات القانونية لفترة ضرورية فقط.',
        ),
        _PolicySection(
          '4) مدة التنفيذ',
          'نهدف إلى تنفيذ طلبات الحذف خلال 30 يومًا ما لم توجد التزامات قانونية أو نزاعات مفتوحة.',
        ),
      ];
    }

    return const [
      _PolicySection(
        '1) How to request deletion',
        'You can request account deletion from settings or by contacting support@laqta.cloud.',
      ),
      _PolicySection(
        '2) What is deleted',
        'We delete account, profile, and content data that is not required for legal or operational retention.',
      ),
      _PolicySection(
        '3) Temporary retention',
        'Limited security, dispute, or legal records may be retained only as needed.',
      ),
      _PolicySection(
        '4) Timeline',
        'We aim to process deletion requests within 30 days unless legal obligations or open disputes apply.',
      ),
    ];
  }

  List<_PolicySection> _contentSections(bool isArabic) {
    if (isArabic) {
      return const [
        _PolicySection(
          '1) المحتوى المحظور',
          'يُمنع نشر محتوى عنيف، بالغ، مسيء، مضلل، أو ينتهك خصوصية الآخرين.',
        ),
        _PolicySection(
          '2) الصور المسروقة والانتحال',
          'يُمنع استخدام صور لا تملك حقوقها أو انتحال هوية مصور، قاعة، أو مستخدم آخر.',
        ),
        _PolicySection(
          '3) الاحتيال والمضايقة',
          'يُمنع الاحتيال، التحرش، التهديد، أو محاولة نقل المستخدمين خارج المنصة بطرق مخالفة.',
        ),
        _PolicySection(
          '4) البلاغات والإجراءات',
          'يمكن للمستخدمين الإبلاغ عن المحتوى أو الحسابات، وتراجع الإدارة البلاغات لاتخاذ إجراء مناسب.',
        ),
      ];
    }

    return const [
      _PolicySection(
        '1) Prohibited content',
        'Violent, adult, abusive, misleading, or privacy-invasive content is prohibited.',
      ),
      _PolicySection(
        '2) Stolen photos and impersonation',
        'Do not use photos you do not own or impersonate another creator, venue, or user.',
      ),
      _PolicySection(
        '3) Fraud and harassment',
        'Fraud, harassment, threats, and abusive off-platform solicitation are prohibited.',
      ),
      _PolicySection(
        '4) Reports and enforcement',
        'Users can report content or accounts. LAQTA reviews reports and may take action.',
      ),
    ];
  }

  Widget _buildSection(BuildContext context, String title, String body) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _PolicySection {
  final String title;
  final String body;

  const _PolicySection(this.title, this.body);
}
