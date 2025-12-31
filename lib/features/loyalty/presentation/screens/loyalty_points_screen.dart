import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/loyalty/domain/entities/loyalty_points.dart';
import 'package:luqta/features/loyalty/loyalty_dependencies.dart';

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
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        // Handle not logged in
        setState(() => _isLoading = false);
        return;
      }

      final result = await LoyaltyDependencies.getLoyaltyPoints().call(
        userId: userId,
      );
      if (!result.isSuccess || result.valueOrNull == null) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load loyalty points',
        );
      }
      _loyaltyPoints = result.valueOrNull!;
    } catch (e) {
      // Handle error, perhaps show a snackbar or log
      debugPrint('Error loading loyalty points: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('نقاط الولاء 🎁'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showPointsInfo,
          ),
        ],
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
              Text('السجل', style: AppTypography.h3),
              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          const SizedBox(height: 12),
          ..._loyaltyPoints.transactions.take(5).map(_buildTransactionCard),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.cta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
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
                'نقاطك المتاحة',
                style: AppTypography.h4.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                _loyaltyPoints.getTierName(),
                style: AppTypography.h4.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_loyaltyPoints.availablePoints}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'نقطة',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
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
                _buildPointsStat('المجموع', '${_loyaltyPoints.totalPoints}'),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildPointsStat('المستخدم', '${_loyaltyPoints.usedPoints}'),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildPointsStat(
                  'الخصم',
                  '${_loyaltyPoints.getDiscountPercentage()}%',
                ),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTierProgress() {
    final nextTierPoints = _loyaltyPoints.getPointsForNextTier();
    final progress = _loyaltyPoints.getTierProgress();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('التقدم للمستوى التالي', style: AppTypography.h4),
              if (nextTierPoints > 0)
                Text(
                  'باقي $nextTierPoints نقطة',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
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
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🥉 برونزي', style: AppTypography.bodySmall),
              Text('🥈 فضي', style: AppTypography.bodySmall),
              Text('🥇 ذهبي', style: AppTypography.bodySmall),
              Text('💎 بلاتينيوم', style: AppTypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarn() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('كيف تكسب النقاط؟', style: AppTypography.h4),
          const SizedBox(height: 16),
          _buildEarnMethod(
            '📅',
            'إتمام حجز',
            '+${PointsRules.bookingCompleted} نقطة',
          ),
          _buildEarnMethod(
            '👥',
            'دعوة صديق',
            '+${PointsRules.referralSuccess} نقطة',
          ),
          _buildEarnMethod(
            '⭐',
            'كتابة تقييم',
            '+${PointsRules.reviewWritten} نقطة',
          ),
          _buildEarnMethod(
            '🎉',
            'أول حجز',
            '+${PointsRules.firstBooking} نقطة',
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMethod(String emoji, String title, String points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTypography.bodyMedium)),
          Text(
            points,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PointTransaction transaction) {
    final isEarned = transaction.type == 'earned';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (isEarned ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.getIcon(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.getTitle(), style: AppTypography.bodyLarge),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarned ? '+' : ''}${transaction.points}',
                style: AppTypography.h4.copyWith(
                  color: isEarned ? AppColors.success : AppColors.error,
                ),
              ),
              Text(
                _formatDate(transaction.createdAt),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
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

    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPointsInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات النقاط', style: AppTypography.h3),
            const SizedBox(height: 16),
            Text(
              '• كل ${PointsRules.pointsToIQD} نقطة = 1,000 دينار عراقي\n'
              '• يمكن استخدام النقاط كخصم على الحجوزات\n'
              '• النقاط لا تنتهي صلاحيتها\n'
              '• كلما ارتفع مستواك، زادت الخصومات\n'
              '• شارك رمز الإحالة واكسب نقاط إضافية',
              style: AppTypography.bodyMedium.copyWith(height: 1.8),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
