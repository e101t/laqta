import 'package:flutter/material.dart';
import 'package:laqta/core/models/achievement_model.dart';
import 'package:laqta/core/widgets/skeleton_loaders.dart';
import 'package:laqta/features/achievements/achievements_dependencies.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _isLoading = true;
  List<Achievement> _achievements = [];
  Map<String, UserAchievement> _userAchievements = {};
  int _totalPoints = 0;
  int _unlockedCount = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      if (!mounted) return;
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      // Load all achievements
      final achievements = Achievement.getAllAchievements();

      // Load user achievements from Firestore
      final userAchievements = <String, UserAchievement>{};
      final result = await AchievementsDependencies.getUserAchievements().call(
        userId: userId,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load achievements',
        );
      }
      for (final userAchievement in result.valueOrNull ?? []) {
        userAchievements[userAchievement.achievementId] = userAchievement;
      }

      // Create entries for achievements not yet started
      for (final achievement in achievements) {
        if (!userAchievements.containsKey(achievement.achievementId)) {
          userAchievements[achievement.achievementId] = UserAchievement(
            userId: userId,
            achievementId: achievement.achievementId,
            currentProgress: 0,
            isUnlocked: false,
          );
        }
      }

      setState(() {
        _achievements = achievements;
        _userAchievements = userAchievements;
        _unlockedCount = userAchievements.values
            .where((ua) => ua.isUnlocked)
            .length;
        _totalPoints = achievements
            .where(
              (a) => userAchievements[a.achievementId]?.isUnlocked ?? false,
            )
            .fold(0, (total, a) => total + a.rewardPoints);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load achievements';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('الإنجازات 🏆'), centerTitle: true),
      body: _isLoading
          ? SkeletonList(
              itemBuilder: const _AchievementSkeleton(),
              itemCount: 6,
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: scheme.error),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAchievements,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats Card
                _buildStatsCard(),
                const SizedBox(height: 24),

                // Progress Overview
                Text('التقدم', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildProgressCard(),
                const SizedBox(height: 24),

                // Achievements List
                Text('جميع الإنجازات', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                ..._achievements.map((achievement) {
                  final userAchievement =
                      _userAchievements[achievement.achievementId];
                  return _AchievementCard(
                    achievement: achievement,
                    userAchievement: userAchievement,
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildStatsCard() {
    final scheme = Theme.of(context).colorScheme;
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
            color: scheme.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            '$_unlockedCount / ${_achievements.length}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'إنجاز مفتوح',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '$_totalPoints نقطة مكتسبة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _unlockedCount / _achievements.length;
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
              Text('التقدم الكلي', style: textTheme.titleMedium),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: textTheme.titleMedium?.copyWith(
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
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement? userAchievement;

  const _AchievementCard({required this.achievement, this.userAchievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isUnlocked = userAchievement?.isUnlocked ?? false;
    final progress = userAchievement?.getProgress(achievement) ?? 0.0;
    final currentProgress = userAchievement?.currentProgress ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? scheme.primary.withValues(alpha: 0.06)
            : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? scheme.primary.withValues(alpha: 0.30)
              : scheme.outlineVariant,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.3,
                child: Text(
                  achievement.icon,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? scheme.primary : null,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Icon(
                        Icons.check_circle,
                        color: scheme.tertiary,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress
                if (!isUnlocked) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: scheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$currentProgress/${achievement.requiredCount}',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],

                // Reward
                if (achievement.rewardPoints > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, size: 14, color: scheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          '+${achievement.rewardPoints} نقطة',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementSkeleton extends StatelessWidget {
  const _AchievementSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 70, height: 70),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: double.infinity, height: 18),
                  const SizedBox(height: 8),
                  const SkeletonBox(width: 200, height: 14),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    width: double.infinity,
                    height: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
