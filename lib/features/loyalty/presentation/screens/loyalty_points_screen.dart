import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/loyalty/domain/entities/loyalty_points.dart';
import 'package:laqta/features/loyalty/loyalty_dependencies.dart';

class LoyaltyPointsScreen extends StatefulWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  State<LoyaltyPointsScreen> createState() => _LoyaltyPointsScreenState();
}

class _LoyaltyPointsScreenState extends State<LoyaltyPointsScreen> {
  late LoyaltyPoints _loyaltyPoints;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    setState(() => _isLoading = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      if (!mounted) return;
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        // Handle not logged in
        setState(() => _isLoading = false);
        return;
      }

      final result = await LoyaltyDependencies.getLoyaltyPoints().call(userId: userId);
      if (!mounted) return;
      if (!result.isSuccess || result.valueOrNull == null) {
        throw StateError(result.failureOrNull?.message ?? 'Failed to load loyalty points');
      }
      _loyaltyPoints = result.valueOrNull!;
    } catch (e) {
      // Handle error, perhaps show a snackbar or log
      if (kDebugMode) {
        debugPrint('Error loading loyalty points: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ù†Ù‚Ø§Ø· Ø§Ù„ÙˆÙ„Ø§Ø¡ ðŸŽ'),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.info_outline), onPressed: _showPointsInfo)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Points Card
          _buildPointsCard(),
          const SizedBox(height: 24),

          // Tier Progress
          _buildTierProgress(),
          const SizedBox(height: 24),

          // How to Earn Points
          _buildHowToEarn(),
          const SizedBox(height: 24),

          // Transactions History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ø§Ù„Ø³Ø¬Ù„', style: textTheme.titleLarge),
              TextButton(onPressed: () {}, child: const Text('Ø¹Ø±Ø¶ Ø§Ù„ÙƒÙ„')),
            ],
          ),
          const SizedBox(height: 12),
          ..._loyaltyPoints.transactions.take(5).map(_buildTransactionCard),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ù†Ù‚Ø§Ø·Ùƒ Ø§Ù„Ù…ØªØ§Ø­Ø©',
                style: textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
              Text(
                _loyaltyPoints.getTierName(),
                style: textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_loyaltyPoints.availablePoints}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Ù†Ù‚Ø·Ø©',
            style: textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPointsStat('Ø§Ù„Ù…Ø¬Ù…ÙˆØ¹', '${_loyaltyPoints.totalPoints}'),
                Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                _buildPointsStat('Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…', '${_loyaltyPoints.usedPoints}'),
                Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                _buildPointsStat('Ø§Ù„Ø®ØµÙ…', '${_loyaltyPoints.getDiscountPercentage()}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildTierProgress() {
    final nextTierPoints = _loyaltyPoints.getPointsForNextTier();
    final progress = _loyaltyPoints.getTierProgress();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ø§Ù„ØªÙ‚Ø¯Ù… Ù„Ù„Ù…Ø³ØªÙˆÙ‰ Ø§Ù„ØªØ§Ù„ÙŠ', style: textTheme.titleMedium),
              if (nextTierPoints > 0)
                Text(
                  'Ø¨Ø§Ù‚ÙŠ $nextTierPoints Ù†Ù‚Ø·Ø©',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ðŸ¥‰ Ø¨Ø±ÙˆÙ†Ø²ÙŠ', style: textTheme.bodySmall),
              Text('ðŸ¥ˆ ÙØ¶ÙŠ', style: textTheme.bodySmall),
              Text('ðŸ¥‡ Ø°Ù‡Ø¨ÙŠ', style: textTheme.bodySmall),
              Text('ðŸ’Ž Ø¨Ù„Ø§ØªÙŠÙ†ÙŠÙˆÙ…', style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarn() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ÙƒÙŠÙ ØªÙƒØ³Ø¨ Ø§Ù„Ù†Ù‚Ø§Ø·ØŸ', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          _buildEarnMethod('ðŸ“…', 'Ø¥ØªÙ…Ø§Ù… Ø­Ø¬Ø²', '+${PointsRules.bookingCompleted} Ù†Ù‚Ø·Ø©'),
          _buildEarnMethod('ðŸ‘¥', 'Ø¯Ø¹ÙˆØ© ØµØ¯ÙŠÙ‚', '+${PointsRules.referralSuccess} Ù†Ù‚Ø·Ø©'),
          _buildEarnMethod('â­', 'ÙƒØªØ§Ø¨Ø© ØªÙ‚ÙŠÙŠÙ…', '+${PointsRules.reviewWritten} Ù†Ù‚Ø·Ø©'),
          _buildEarnMethod('ðŸŽ‰', 'Ø£ÙˆÙ„ Ø­Ø¬Ø²', '+${PointsRules.firstBooking} Ù†Ù‚Ø·Ø©'),
        ],
      ),
    );
  }

  Widget _buildEarnMethod(String emoji, String title, String points) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: textTheme.bodyMedium)),
          Text(
            points,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PointTransaction transaction) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEarned = transaction.type == 'earned';
    final accent = isEarned ? scheme.tertiary : scheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(transaction.getIcon(), style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.getTitle(), style: textTheme.bodyLarge),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarned ? '+' : ''}${transaction.points}',
                style: textTheme.titleMedium?.copyWith(color: accent),
              ),
              Text(
                _formatDate(transaction.createdAt),
                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Ø§Ù„ÙŠÙˆÙ…';
    if (diff.inDays == 1) return 'Ø£Ù…Ø³';
    if (diff.inDays < 7) return 'Ù…Ù†Ø° ${diff.inDays} Ø£ÙŠØ§Ù…';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPointsInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ù†Ù‚Ø§Ø·', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              'â€¢ ÙƒÙ„ ${PointsRules.pointsToIQD} Ù†Ù‚Ø·Ø© = 1,000 Ø¯ÙŠÙ†Ø§Ø± Ø¹Ø±Ø§Ù‚ÙŠ\n'
              'â€¢ ÙŠÙ…ÙƒÙ† Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø§Ù„Ù†Ù‚Ø§Ø· ÙƒØ®ØµÙ… Ø¹Ù„Ù‰ Ø§Ù„Ø­Ø¬ÙˆØ²Ø§Øª\n'
              'â€¢ Ø§Ù„Ù†Ù‚Ø§Ø· Ù„Ø§ ØªÙ†ØªÙ‡ÙŠ ØµÙ„Ø§Ø­ÙŠØªÙ‡Ø§\n'
              'â€¢ ÙƒÙ„Ù…Ø§ Ø§Ø±ØªÙØ¹ Ù…Ø³ØªÙˆØ§ÙƒØŒ Ø²Ø§Ø¯Øª Ø§Ù„Ø®ØµÙˆÙ…Ø§Øª\n'
              'â€¢ Ø´Ø§Ø±Ùƒ Ø±Ù…Ø² Ø§Ù„Ø¥Ø­Ø§Ù„Ø© ÙˆØ§ÙƒØ³Ø¨ Ù†Ù‚Ø§Ø· Ø¥Ø¶Ø§ÙÙŠØ©',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
