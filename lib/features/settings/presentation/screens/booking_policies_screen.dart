import 'package:flutter/material.dart';

class BookingPoliciesScreen extends StatelessWidget {
  const BookingPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final sections = [
      _PolicySection(
        title: 'سياسة الضمان (Escrow)',
        content:
            'عربون الحجز يبقى داخل لقطه ولا يُحرَّر للمصور إلا بعد قبول العميل للتسليم أو انتهاء فترة الاعتراض (72 ساعة بعد التسليم).',
      ),
      _PolicySection(
        title: 'سياسة التعديل',
        content:
            'تعديل واحد مجاني ضمن نطاق وصف الطلب، وكل ما يتجاوز الوعد يتحول إلى خدمة إضافية تتطلب عرضاً جديداً أو مبلغاً إضافياً.',
      ),
      _PolicySection(
        title: 'سياسة الإلغاء',
        content:
            'قبل 48 ساعة: استرجاع كامل للعربون. خلال 48 ساعة: استرجاع جزئي + تعويض للمصور. إذا المصور لم يحضر/ألغى: استرجاع كامل + أثر على الثقة.',
      ),
      _PolicySection(
        title: 'سياسة الخصوصية',
        content:
            'لا نشارك أرقام الهواتف قبل تأكيد الحجز؛ كل التواصل داخل المنصة، والملفات تظل ضمن الخوادم مع روابط تحميل مؤقتة.',
      ),
      _PolicySection(
        title: 'سياسة النزاعات',
        content:
            'النزاع يُفتح داخل الحجز فقط. الطرفان يرفعان أدلة (صور/دردشة/وقت)، والإدارة تصدر قراراً نهائياً خلال 3 أيام.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('سياسات غرف الحجز'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sections[index].title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sections[index].content,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicySection {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});
}
