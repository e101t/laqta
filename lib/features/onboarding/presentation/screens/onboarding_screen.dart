import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:laqta/app/router/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;
  late final AnimationController _fadeCtrl;

  static const _slides = [
    _Slide(
      icon: Icons.camera_alt_rounded,
      title: 'التقط اللحظة',
      subtitle:
          'اكتشف أفضل المصورين في مدينتك واحجز جلستك في ثوانٍ',
      color: Color(0xFFD6A44A),
    ),
    _Slide(
      icon: Icons.wb_sunny_rounded,
      title: 'الساعة الذهبية',
      subtitle:
          'احجز خلال الساعة الذهبية للحصول على أجمل إضاءة طبيعية لصورك',
      color: Color(0xFFFF9500),
    ),
    _Slide(
      icon: Icons.explore_rounded,
      title: 'ابدأ رحلتك',
      subtitle:
          'سجّل حسابك الآن وانضم إلى آلاف العملاء والمصورين في منصة لقطة',
      color: Color(0xFF3B82F6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    HapticFeedback.lightImpact();
    if (_page < _slides.length - 1) {
      await _fadeCtrl.reverse();
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _fadeCtrl.forward();
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go(Routes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];

    return Scaffold(
      backgroundColor: const Color(0xFF0E1014),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'تخطي',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) {
                  setState(() => _page = i);
                  _fadeCtrl
                    ..reset()
                    ..forward();
                },
                itemBuilder: (context, index) {
                  return _SlideView(slide: _slides[index]);
                },
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? slide.color : Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: slide.color,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _page < _slides.length - 1 ? 'التالي' : 'ابدأ الآن',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon inside glowing circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.color.withValues(alpha: 0.10),
              border: Border.all(
                color: slide.color.withValues(alpha: 0.30),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.color.withValues(alpha: 0.18),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(slide.icon, size: 64, color: slide.color),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
