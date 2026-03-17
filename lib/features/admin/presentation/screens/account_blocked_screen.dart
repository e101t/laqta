import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';

class AccountBlockedScreen extends StatelessWidget {
  const AccountBlockedScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await AuthDependencies.signOut().call();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 64, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                localizations.accountBlocked,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                localizations.accountBlockedMessage,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CTAButton(
                text: localizations.signOut,
                onPressed: () => _signOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
