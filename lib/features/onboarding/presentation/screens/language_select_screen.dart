import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/providers/locale_provider.dart';
import 'package:laqta/app/router/app_router.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _headerFade;
  late final Animation<double> _cardFadeOne;
  late final Animation<double> _cardFadeTwo;
  late final Animation<double> _hintFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<Offset> _cardSlideOne;
  late final Animation<Offset> _cardSlideTwo;
  late final Animation<Offset> _hintSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _cardFadeOne = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
    );
    _cardFadeTwo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.82, curve: Curves.easeOut),
    );
    _hintFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_headerFade);
    _cardSlideOne = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_cardFadeOne);
    _cardSlideTwo = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_cardFadeTwo);
    _hintSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_hintFade);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(BuildContext context, String languageCode) async {
    final localeProvider = context.read<LocaleProvider>();
    await localeProvider.setLocale(languageCode);
    if (!context.mounted) return;
    AppRouter.goToAuth(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surface,
                  scheme.primary.withValues(alpha: 0.08),
                  scheme.secondary.withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -80,
            child: _SoftOrb(
              size: 220,
              color: scheme.primary.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: _SoftOrb(
              size: 260,
              color: scheme.secondary.withValues(alpha: 0.16),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.92,
                              end: 1,
                            ).animate(_headerFade),
                            child: Container(
                              height: 88,
                              width: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    scheme.primary.withValues(alpha: 0.8),
                                    scheme.secondary.withValues(alpha: 0.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.primary.withValues(alpha: 0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.translate_rounded,
                                color: scheme.onPrimary,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            localizations.selectLanguage,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.selectLanguageSubtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      final currentCode = localeProvider.locale.languageCode;
                      return Column(
                        children: [
                          FadeTransition(
                            opacity: _cardFadeOne,
                            child: SlideTransition(
                              position: _cardSlideOne,
                              child: _LanguageCard(
                                title: 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©',
                                subtitle: 'Arabic',
                                isSelected: currentCode == 'ar',
                                onTap: () => _selectLanguage(context, 'ar'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _cardFadeTwo,
                            child: SlideTransition(
                              position: _cardSlideTwo,
                              child: _LanguageCard(
                                title: 'English',
                                subtitle: 'Ø§Ù„Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠØ©',
                                isSelected: currentCode == 'en',
                                onTap: () => _selectLanguage(context, 'en'),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _hintFade,
                    child: SlideTransition(
                      position: _hintSlide,
                      child: Text(
                        localizations.languageHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.1)
              : scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isSelected ? 0.12 : 0.06),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isSelected
                  ? scheme.primary.withValues(alpha: 0.2)
                  : scheme.primary.withValues(alpha: 0.12),
              child: Text(
                title.characters.first,
                style: textTheme.titleMedium?.copyWith(color: scheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1 : 0.9,
                child: Icon(Icons.check_circle, color: scheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
