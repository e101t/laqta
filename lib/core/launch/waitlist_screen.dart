import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/launch/launch_config.dart';
import 'package:laqta/core/launch/launch_config_service.dart';

class WaitlistScreen extends StatefulWidget {
  const WaitlistScreen({
    super.key,
    required this.city,
    required this.capacityReached,
    required this.service,
    required this.onRetry,
  });

  final String city;
  final bool capacityReached;
  final LaunchConfigService service;
  final VoidCallback onRetry;

  @override
  State<WaitlistScreen> createState() => _WaitlistScreenState();
}

class _WaitlistScreenState extends State<WaitlistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late final TextEditingController _cityController = TextEditingController(
    text: widget.city,
  );
  String _roleInterest = 'customer';
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.service.submitWaitlist(
        WaitlistEntryInput(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          roleInterest: _roleInterest,
        ),
      );
      if (!mounted) return;
      setState(() {
        _submitted = true;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.current.waitlistSubmitFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = widget.capacityReached
        ? AppLocalizations.current.waitlistFullMsg
        : AppLocalizations.current.waitlistBaghdadOnly;
    final subtitle = widget.capacityReached
        ? AppLocalizations.current.waitlistNotifyExpansion
        : AppLocalizations.current.waitlistNotifyCity;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _submitted
                  ? _SubmittedState(onRetry: widget.onRetry)
                  : Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.hourglass_top_rounded,
                            color: scheme.primary,
                            size: 56,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.current.nameLabel,
                            ),
                            validator: (value) =>
                                value == null || value.trim().length < 2
                                ? AppLocalizations.current.enterName
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.current.phoneNumber,
                            ),
                            validator: (value) =>
                                value == null || value.trim().length < 6
                                ? AppLocalizations.current.enterValidPhone
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _cityController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.current.cityLabel,
                            ),
                            validator: (value) =>
                                value == null || value.trim().length < 2
                                ? AppLocalizations.current.enterCity
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _roleInterest,
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.current.accountTypeLabel,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'customer',
                                child: Text(AppLocalizations.current.userLabel),
                              ),
                              DropdownMenuItem(
                                value: 'photographer',
                                child: Text(AppLocalizations.current.photographer),
                              ),
                              DropdownMenuItem(
                                value: 'venue',
                                child: Text(AppLocalizations.current.venuePlaceLabel),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _roleInterest = value);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(AppLocalizations.current.registerInterest),
                          ),
                          TextButton(
                            onPressed: widget.onRetry,
                            child: Text(AppLocalizations.current.recheckAction),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmittedState extends StatelessWidget {
  const _SubmittedState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 64),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.current.interestRegistered,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.current.notifyOnExpand,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OutlinedButton(onPressed: onRetry, child: Text(AppLocalizations.current.recheckAction)),
      ],
    );
  }
}
