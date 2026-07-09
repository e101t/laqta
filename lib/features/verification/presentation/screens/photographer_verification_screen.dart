import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
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
        SnackBar(content: Text(AppLocalizations.current.verificationRequestSent)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(AppLocalizations.current.verificationRequestFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.current.photographerVerificationTitle)),
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
                AppLocalizations.current.verifyAccountPrompt,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _StatusTile(
                title: AppLocalizations.current.requestStatus,
                value: _statusLabel(status.status),
                done: status.status == 'verified',
              ),
              _StatusTile(
                title: AppLocalizations.current.phoneNumber,
                value: status.phoneVerified
                    ? AppLocalizations.current.verifiedLabel
                    : AppLocalizations.current.notVerifiedLabel,
                done: status.phoneVerified,
              ),
              _StatusTile(
                title: AppLocalizations.current.portfolioReview,
                value: status.portfolioReviewed
                    ? AppLocalizations.current.completedLabel
                    : AppLocalizations.current.awaitingReview,
                done: status.portfolioReviewed,
              ),
              _StatusTile(
                title: AppLocalizations.current.identityReview,
                value: status.identityReviewed
                    ? AppLocalizations.current.completedLabel
                    : AppLocalizations.current.awaitingReview,
                done: status.identityReviewed,
              ),
              if (status.rejectionReason != null) ...[
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.current.rejectionReason('${status.rejectionReason}'),
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
                    : Text(AppLocalizations.current.sendVerificationRequest),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'verified' => AppLocalizations.current.verifiedLabel,
      'pending' => AppLocalizations.current.underReview,
      'rejected' => AppLocalizations.current.rejectedLabel,
      _ => AppLocalizations.current.notSubmitted,
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
