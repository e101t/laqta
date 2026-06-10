import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class CampaignAnalyticsScreen extends StatelessWidget {
  final String campaignId;

  const CampaignAnalyticsScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CampaignAnalyticsController(
        MarketplaceDependencies.repository,
        campaignId,
      )..load(),
      child: const _CampaignAnalyticsView(),
    );
  }
}

class _CampaignAnalyticsView extends StatelessWidget {
  const _CampaignAnalyticsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CampaignAnalyticsController>();
    final campaign = controller.campaign;

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      appBar: AppBar(
        backgroundColor: LaqtaColors.canvasDark,
        foregroundColor: Colors.white,
        title: const Text('تحليلات الحملة'),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  controller.error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : campaign == null
          ? const Center(
              child: Text(
                'لا توجد حملة لعرضها.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LaqtaLuxurySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusLabel(campaign.status),
                        style: const TextStyle(
                          color: LaqtaColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'الانطباعات',
                              value: '${campaign.analytics.impressions}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              label: 'النقرات',
                              value: '${campaign.analytics.clicks}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'CTR',
                              value:
                                  '${campaign.analytics.ctr.toStringAsFixed(2)}%',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              label: 'الإنفاق',
                              value:
                                  '\$${campaign.analytics.spendAmount.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LaqtaLuxurySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الميزانية',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _BudgetRow(
                        label: 'الإجمالي',
                        value: campaign.budgetTotal,
                      ),
                      _BudgetRow(label: 'اليومي', value: campaign.dailyBudget),
                      _BudgetRow(label: 'المصروف', value: campaign.spentAmount),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LaqtaLuxurySurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الأهداف',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...campaign.targets.map(
                        (target) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.ads_click_outlined,
                                color: LaqtaColors.accent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${target.targetType} • ${target.entityId}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _statusLabel(MarketplaceCampaignStatus status) {
    switch (status) {
      case MarketplaceCampaignStatus.pendingReview:
        return 'قيد المراجعة';
      case MarketplaceCampaignStatus.approved:
        return 'تمت الموافقة';
      case MarketplaceCampaignStatus.rejected:
        return 'مرفوضة';
      case MarketplaceCampaignStatus.active:
        return 'نشطة';
      case MarketplaceCampaignStatus.paused:
        return 'متوقفة';
      case MarketplaceCampaignStatus.completed:
        return 'مكتملة';
      case MarketplaceCampaignStatus.draft:
        return 'مسودة';
    }
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E23),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LaqtaColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double value;

  const _BudgetRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: LaqtaColors.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
