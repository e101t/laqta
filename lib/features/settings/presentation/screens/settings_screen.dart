import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/providers/theme_provider.dart';
import 'package:luqta/core/providers/locale_provider.dart';
import 'package:luqta/app/router/app_router.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/settings/presentation/screens/policies_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luqta/features/settings/settings_dependencies.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _reduceMotion = prefs.getBool('reduceMotion') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('reduceMotion', _reduceMotion);
  }

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);
    _saveSettings();
  }

  void _toggleDarkMode(bool value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme();
  }

  void _toggleReduceMotion(bool value) {
    setState(() => _reduceMotion = value);
    _saveSettings();
  }

  void _changeLanguage(String? value) {
    if (value != null) {
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      localeProvider.setLocale(value);
      final localizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.languageChanged)));
    }
  }

  void _showDeleteAccountDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteAccount),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => _deleteAccount(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No user logged in')));
        return;
      }

      // Delete user data from Firestore
      final result = await SettingsDependencies.deleteUserData().call(
        userId: userId,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to delete user data',
        );
      }

      // Delete user account from Firebase Auth
      final authDeleteResult = await AuthDependencies.deleteCurrentUser()
          .call();
      if (!authDeleteResult.isSuccess) {
        throw StateError(
          authDeleteResult.failureOrNull?.message ??
              'Failed to delete auth account',
        );
      }

      // Clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to auth screen
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      AppRouter.goToAuth(context);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete account')));
    }
  }

  Future<void> _logout() async {
    try {
      final result = await AuthDependencies.signOut().call();
      if (!result.isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${result.failureOrNull?.message}'),
          ),
        );
        return;
      }

      // Clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to auth screen
      if (!mounted) return;
      AppRouter.goToAuth(context);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to logout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader(localizations.notificationsSection),
          SwitchListTile(
            title: Text(localizations.enableNotifications),
            subtitle: const Text('استلام تحديثات الحجوزات والرسائل'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader('${localizations.appearanceSection} 🎨'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(localizations.darkMode),
                subtitle: Text(localizations.darkModeSubtitle),
                value: themeProvider.isDarkMode,
                onChanged: _toggleDarkMode,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          const Divider(),

          // Accessibility Section
          _buildSectionHeader(localizations.accessibilitySection),
          SwitchListTile(
            title: Text(localizations.reduceMotion),
            subtitle: Text(localizations.reduceMotionSubtitle),
            value: _reduceMotion,
            onChanged: _toggleReduceMotion,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),

          // Language Section
          _buildSectionHeader(localizations.language),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return ListTile(
                title: Text(localizations.language),
                subtitle: Text(
                  localeProvider.locale.languageCode == 'ar'
                      ? 'العربية'
                      : 'English',
                ),
                trailing: DropdownButton<String>(
                  value: localeProvider.locale.languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: _changeLanguage,
                ),
              );
            },
          ),
          const Divider(),

          // Legal Section
          _buildSectionHeader(localizations.legalSection),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(localizations.policies),
            subtitle: const Text('Read platform policies & terms'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PoliciesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(localizations.bookingPolicies),
            subtitle: const Text('ضمان الحجز، التعديلات، النزاعات'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRouter.goToBookingPolicies(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(localizations.privacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRouter.goToPolicy(context),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(localizations.terms),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => AppRouter.goToTerms(context),
          ),
          const Divider(),

          // Account Actions
          _buildSectionHeader(localizations.accountSection),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              localizations.logout,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: _logout,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              localizations.deleteAccount,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _showDeleteAccountDialog(localizations),
          ),

          const SizedBox(height: 32),

          // App Version
          Center(
            child: Text(
              'Luqta v1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
