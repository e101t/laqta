import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/marketplace/marketplace_dependencies.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/presentation/controllers/marketplace_controllers.dart';

class SponsoredAdScreen extends StatelessWidget {
  const SponsoredAdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: MarketplaceDependencies.sessionService.getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: LaqtaColors.canvasDark,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ChangeNotifierProvider(
          create: (_) => SponsoredAdController(
            MarketplaceDependencies.repository,
            snapshot.data,
          )..load(),
          child: const _SponsoredAdView(),
        );
      },
    );
  }
}

class _SponsoredAdView extends StatelessWidget {
  const _SponsoredAdView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SponsoredAdController>();
    final targetLabel =
        controller.selectedTarget?.label ??
        switch (controller.selectedType) {
          MarketplaceCampaignType.promoteProfile => 'حسابي',
          MarketplaceCampaignType.promoteReel => 'ريل مميز',
          MarketplaceCampaignType.promoteStory => 'ستوري مميزة',
          MarketplaceCampaignType.promoteVenue => 'قاعة أو مكان',
        };

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Row(
              textDirection: TextDirection.ltr,
              children: [
                const LaqtaHeaderBackButton(),
                const Spacer(),
                Text(
                  'إعلان ممول',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'اختر ما تريد ترويجه',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: _selectTile(
                    context,
                    controller,
                    MarketplaceCampaignType.promoteProfile,
                    'الحساب',
                    Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectTile(
                    context,
                    controller,
                    MarketplaceCampaignType.promoteReel,
                    'ريل',
                    Icons.ondemand_video_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectTile(
                    context,
                    controller,
                    MarketplaceCampaignType.promoteStory,
                    'ستوري',
                    Icons.circle_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'العنصر المستهدف',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            LaqtaLuxurySurface(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      targetLabel,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'مدة الإعلان',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              textDirection: TextDirection.ltr,
              children: [14, 7, 3]
                  .map(
                    (value) => Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: InkWell(
                          onTap: () => controller.selectDuration(value),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.selectedDurationDays == value
                                  ? Colors.transparent
                                  : const Color(0xFF17191F),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: controller.selectedDurationDays == value
                                    ? LaqtaColors.accent
                                    : const Color(0xFF2A2D33),
                              ),
                            ),
                            child: Text(
                              '$value ${value == 14 ? 'يوم' : 'أيام'}',
                              style: TextStyle(
                                color: controller.selectedDurationDays == value
                                    ? LaqtaColors.accent
                                    : Colors.white70,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 24),
            Text(
              'المنطقة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: _regionButton(context, controller, 'كل العراق'),
                ),
                const SizedBox(width: 10),
                Expanded(child: _regionButton(context, controller, 'محافظة')),
                const SizedBox(width: 10),
                Expanded(child: _regionButton(context, controller, 'بغداد')),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: LaqtaSkeletonBox(
                  height: 54,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
            LaqtaLuxurySurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الميزانية',
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            controller.setBudget(controller.budget - 5),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '\$${controller.budget}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: LaqtaColors.accent,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            controller.setBudget(controller.budget + 5),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: controller.isSubmitting
                    ? null
                    : () async {
                        if (controller.selectedTarget == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'سجّل الدخول أولًا أو اختر عنصرًا صالحًا للترويج.',
                              ),
                            ),
                          );
                          return;
                        }
                        final campaign = await controller.createAndSubmit();
                        if (!context.mounted) {
                          return;
                        }
                        if (campaign == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                controller.error ?? 'تعذر إنشاء الحملة.',
                              ),
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إنشاء الحملة وإرسالها للمراجعة.'),
                          ),
                        );
                        AppRouter.goToCampaignAnalytics(context, campaign.id);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LaqtaColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Text(
                        'متابعة',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectTile(
    BuildContext context,
    SponsoredAdController controller,
    MarketplaceCampaignType type,
    String label,
    IconData icon,
  ) {
    final selected = controller.selectedType == type;
    return InkWell(
      onTap: () => controller.selectType(type),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 94,
        decoration: BoxDecoration(
          color: const Color(0xFF17191F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? LaqtaColors.accent : LaqtaColors.borderDark,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? LaqtaColors.accent : Colors.white70),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? LaqtaColors.accent : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _regionButton(
    BuildContext context,
    SponsoredAdController controller,
    String value,
  ) {
    final selected = controller.selectedRegion == value;
    return InkWell(
      onTap: () => controller.selectRegion(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF17191F),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? LaqtaColors.accent : LaqtaColors.borderDark,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: selected ? LaqtaColors.accent : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.add_circle_outline,
                color: Colors.white70,
                size: 17,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
