import 'package:flutter/material.dart';
import 'package:laqta/features/verification/data/verification_service.dart';

class PhotographerVerificationScreen extends StatefulWidget {
  const PhotographerVerificationScreen({super.key});

  @override
  State<PhotographerVerificationScreen> createState() =>
      _PhotographerVerificationScreenState();
}

class _PhotographerVerificationScreenState
    extends State<PhotographerVerificationScreen> {
  final VerificationService _service = VerificationService();
  late Future<VerificationStatusModel> _future = _service.getMyVerification();
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final result = await _service.submit();
      if (!mounted) return;
      setState(() {
        _future = Future.value(result);
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب التوثيق للمراجعة.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذّر إرسال طلب التوثيق.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('توثيق المصور')),
      body: FutureBuilder<VerificationStatusModel>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final status = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'وثّق حسابك لزيادة ثقة العملاء ورفع فرص ظهورك.',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _StatusTile(
                title: 'حالة الطلب',
                value: _statusLabel(status.status),
                done: status.status == 'verified',
              ),
              _StatusTile(
                title: 'رقم الهاتف',
                value: status.phoneVerified ? 'موثّق' : 'غير موثّق',
                done: status.phoneVerified,
              ),
              _StatusTile(
                title: 'مراجعة البورتفوليو',
                value: status.portfolioReviewed ? 'مكتملة' : 'بانتظار المراجعة',
                done: status.portfolioReviewed,
              ),
              _StatusTile(
                title: 'مراجعة الهوية',
                value: status.identityReviewed ? 'مكتملة' : 'بانتظار المراجعة',
                done: status.identityReviewed,
              ),
              if (status.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Text(
                  'سبب الرفض: ${status.rejectionReason}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting || status.status == 'pending'
                    ? null
                    : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('إرسال طلب التوثيق'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'verified' => 'موثّق',
      'pending' => 'قيد المراجعة',
      'rejected' => 'مرفوض',
      _ => 'لم يتم الإرسال',
    };
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.title,
    required this.value,
    required this.done,
  });

  final String title;
  final String value;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(
          done ? Icons.check_circle : Icons.pending_outlined,
          color: done ? scheme.primary : scheme.onSurfaceVariant,
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
