import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          SubscriptionPlansController(MarketplaceDependencies.repository)
            ..load(),
      child: const _SubscriptionPlansView(),
    );
  }
}

class _SubscriptionPlansView extends StatelessWidget {
  const _SubscriptionPlansView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SubscriptionPlansController>();
    final currentCode = controller.currentSubscription?.plan.code;
    final plans = [...controller.plans]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  const LaqtaHeaderBackButton(),
                  const Spacer(),
                  Text(
                    'الباقات والاشتراكات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF191B20),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF2A2D33)),
                ),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                      child: _cycleToggle(
                        label: 'سنوي (خصم)',
                        selected: controller.yearly,
                        onTap: () => controller.setYearly(true),
                      ),
                    ),
                    Expanded(
                      child: _cycleToggle(
                        label: 'شهري',
                        selected: !controller.yearly,
                        onTap: () => controller.setYearly(false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (controller.isLoading && plans.isEmpty)
                const SizedBox(
                  height: 380,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (plans.isEmpty && controller.error != null)
                SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (plans.isEmpty)
                const SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      'لا توجد باقات متاحة حالياً',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: plans
                        .map(
                          (plan) => Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: plan == plans.first ? 0 : 10,
                              ),
                              child: _PlanCard(
                                plan: plan,
                                price: _displayPrice(
                                  plan.code,
                                  controller.yearly,
                                ),
                                highlighted: plan.code == 'pro',
                                isCurrent: currentCode == plan.code,
                                isSubscribing: controller.isSubscribing,
                                onSelect: currentCode == plan.code
                                    ? null
                                    : () async {
                                        final success = await controller
                                            .subscribe(plan.code);
                                        if (!context.mounted) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'تم تفعيل باقة ${plan.name}.'
                                                  : (controller.error ??
                                                        'تعذر تفعيل الباقة.'),
                                            ),
                                          ),
                                        );
                                      },
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              const SizedBox(height: 18),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.tune_rounded,
                  color: LaqtaColors.accent,
                  size: 18,
                ),
                label: const Text(
                  'مقارنة الباقات',
                  style: TextStyle(
                    color: LaqtaColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayPrice(String code, bool yearly) {
    final monthly = switch (code) {
      'basic' => 4.99,
      'pro' => 14.99,
      'elite' => 29.99,
      _ => 9.99,
    };
    return yearly
        ? (monthly * 12 * 0.66).toStringAsFixed(2)
        : monthly.toStringAsFixed(2);
  }

  Widget _cycleToggle({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? LaqtaColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  final String price;
  final bool highlighted;
  final bool isCurrent;
  final bool isSubscribing;
  final Future<void> Function()? onSelect;

  const _PlanCard({
    required this.plan,
    required this.price,
    required this.highlighted,
    required this.isCurrent,
    required this.isSubscribing,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      '${plan.portfolioLimit} صور في البورتفوليو',
      '${plan.reelsLimit} ريلز شهريًا',
      if (plan.featuredEnabled) 'ظهور أفضل في البحث',
      if (plan.analyticsEnabled) 'إحصائيات أساسية',
      if (plan.sponsoredDiscountPercent > 0) 'خصم على الإعلانات',
      if (plan.code == 'elite') 'دعم أسرع',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17191F), Color(0xFF121419)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? Colors.greenAccent
              : highlighted
              ? LaqtaColors.accent
              : const Color(0xFF2A2D33),
          width: highlighted || isCurrent ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$$price',
            style: const TextStyle(
              color: LaqtaColors.accent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'شهريًا',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...features
              .take(5)
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(
                          Icons.circle,
                          size: 7,
                          color: LaqtaColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton(
              onPressed: isSubscribing || isCurrent
                  ? null
                  : () => onSelect?.call(),
              style: OutlinedButton.styleFrom(
                backgroundColor: highlighted
                    ? LaqtaColors.accent
                    : Colors.transparent,
                foregroundColor: highlighted
                    ? Colors.black
                    : LaqtaColors.accent,
                side: BorderSide(
                  color: highlighted ? Colors.transparent : LaqtaColors.accent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubscribing && !isCurrent
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isCurrent ? 'مفعّلة' : 'اختر الباقة',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
