import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';

class BookingPoliciesScreen extends StatelessWidget {
  const BookingPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final sections = [
      _PolicySection(
        title: AppLocalizations.current.escrowPolicyTitle,
        content: AppLocalizations.current.escrowPolicyBody,
      ),
      _PolicySection(
        title: AppLocalizations.current.editPolicyTitle,
        content:
            AppLocalizations.current.editPolicyBody,
      ),
      _PolicySection(
        title: AppLocalizations.current.cancelPolicyTitle,
        content:
            AppLocalizations.current.cancelPolicyBody,
      ),
      _PolicySection(
        title: AppLocalizations.current.privacyPolicyTitle,
        content:
            AppLocalizations.current.privacyPolicyBody,
      ),
      _PolicySection(
        title: AppLocalizations.current.disputesPolicyTitle,
        content:
            AppLocalizations.current.disputesPolicyBody,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.current.bookingPoliciesTitle),
        centerTitle: true,
      ),
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
