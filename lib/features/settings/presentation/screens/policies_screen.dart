import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';

class PoliciesScreen extends StatelessWidget {
  const PoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.policies), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.readPolicies,
                    style: textTheme.titleLarge?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ÙÙ‡Ù… ÙˆØ§Ø¶Ø­ Ù„Ù„Ø­Ù‚ÙˆÙ‚ ÙˆØ§Ù„ÙˆØ§Ø¬Ø¨Ø§Øª Ø¹Ù„Ù‰ Ù…Ù†ØµØ© Ù„Ù‚Ø·Ø©',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 1. Escrow Policy
            _PolicySection(
              title: localizations.escrowPolicy,
              icon: 'ðŸ”’',
              children: [
                Text(
                  localizations.escrowPolicyDesc,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _SubSection(
                  title: localizations.escrowReleaseTitle,
                  content: localizations.escrowReleaseDesc,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Revision Policy
            _PolicySection(
              title: localizations.revisionPolicy,
              icon: 'âœï¸',
              children: [
                Text(
                  localizations.revisionPolicyDesc,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _SubSection(
                  title: localizations.revisionExtraTitle,
                  content: localizations.revisionExtraDesc,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Cancellation Policy
            _PolicySection(
              title: localizations.cancellationPolicy,
              icon: 'ðŸš«',
              children: [
                _CancellationRow(
                  icon: 'â°',
                  title: 'Ù‚Ø¨Ù„ 48 Ø³Ø§Ø¹Ø©',
                  desc: localizations.cancellation48Hours,
                ),
                const SizedBox(height: 8),
                _CancellationRow(
                  icon: 'â³',
                  title: 'Ø®Ù„Ø§Ù„ 48 Ø³Ø§Ø¹Ø©',
                  desc: localizations.cancellation48HoursAfter,
                ),
                const SizedBox(height: 8),
                _CancellationRow(
                  icon: 'âš ï¸',
                  title: 'Ø¹Ø¯Ù… Ø§Ù„Ø­Ø¶ÙˆØ±',
                  desc: localizations.cancellationPhotographer,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Dispute Policy
            _PolicySection(
              title: localizations.disputePolicy,
              icon: 'âš–ï¸',
              children: [
                Text(
                  localizations.disputePolicyDesc,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.secondary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: scheme.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.disputeProcess,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.disputeStep1,
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        localizations.disputeStep2,
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        localizations.disputeStep3,
                        style: textTheme.bodyMedium,
                      ),
                      Text(
                        localizations.disputeStep4,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Trust Score
            _PolicySection(
              title: localizations.trustScorePolicy,
              icon: 'â­',
              children: [
                Text(
                  localizations.trustScoreDesc,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TrustMetric(localizations.trustMetric1),
                      _TrustMetric(localizations.trustMetric2),
                      _TrustMetric(localizations.trustMetric3),
                      _TrustMetric(localizations.trustMetric4),
                      _TrustMetric(localizations.trustMetric5),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 6. Privacy Policy
            _PolicySection(
              title: localizations.privacyPolicy,
              icon: 'ðŸ›¡ï¸',
              children: [
                _PrivacyItem(
                  icon: 'ðŸ”’',
                  text: localizations.privacyPhoneNumber,
                ),
                const SizedBox(height: 8),
                _PrivacyItem(icon: 'ðŸ“', text: localizations.privacyFiles),
                const SizedBox(height: 8),
                _PrivacyItem(icon: 'ðŸ’¬', text: localizations.privacyContact),
                const SizedBox(height: 8),
                _PrivacyItem(icon: 'â°', text: localizations.privacyLinks),
              ],
            ),
            const SizedBox(height: 16),

            // 7. Payment Policy
            _PolicySection(
              title: localizations.paymentPolicy,
              icon: 'ðŸ’³',
              children: [
                _PaymentItem(localizations.paymentDeposit),
                const SizedBox(height: 8),
                _PaymentItem(localizations.paymentRelease),
                const SizedBox(height: 8),
                _PaymentItem(localizations.paymentRefund),
              ],
            ),
            const SizedBox(height: 24),

            // Confirmation Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                localizations.iUnderstand,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Policy Section Component
class _PolicySection extends StatelessWidget {
  final String title;
  final String icon;
  final List<Widget> children;

  const _PolicySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sub Section Component
class _SubSection extends StatelessWidget {
  final String title;
  final String content;

  const _SubSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.tertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// Cancellation Row Component
class _CancellationRow extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _CancellationRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

// Trust Metric Component
class _TrustMetric extends StatelessWidget {
  final String text;

  const _TrustMetric(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

// Privacy Item Component
class _PrivacyItem extends StatelessWidget {
  final String icon;
  final String text;

  const _PrivacyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: textTheme.bodyMedium)),
      ],
    );
  }
}

// Payment Item Component
class _PaymentItem extends StatelessWidget {
  final String text;

  const _PaymentItem(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: textTheme.bodyMedium),
    );
  }
}
