import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/utils/debouncer.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/profile/domain/entities/user_profile_update.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';

class BasicInfoScreen extends StatefulWidget {
  final String userRole;

  const BasicInfoScreen({super.key, required this.userRole});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final Debouncer _usernameDebouncer = Debouncer(
    delay: const Duration(milliseconds: 500),
  );

  static const Set<String> _reservedUsernames = {
    'admin',
    'support',
    'system',
    'root',
    'owner',
    'official',
    'laqta',
    'photographer',
    'customer',
    'help',
    'service',
    'staff',
    'admin1',
    'mod',
    'moderator',
    'Ø§Ø¯Ù…Ù€Ù†',
    'Ø§Ø¯Ù…Ù†',
    'Ø§Ù„Ø¯Ø¹Ù…',
    'Ù†Ø¸Ø§Ù…',
    'Ø§Ù„Ù…Ø³Ø§Ø¹Ø¯Ø©',
    'Ù„Ù‚Ø·Ø©',
    'Ù„Ù‚ØªØ©',
  };

  String? _selectedGender;
  String? _selectedGovernorate;
  String? _selectedRole;
  bool _over18Confirmed = false;
  bool _isCheckingUsername = false;
  bool _usernameAvailable = false;
  String? _usernameError;
  bool _isSuggesting = false;
  List<String> _suggestions = [];
  bool _isLoading = false;
  bool _isLoadingInitial = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.userRole.trim().isEmpty ? null : widget.userRole.trim();
    _loadExistingUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthYearController.dispose();
    _usernameDebouncer.dispose();
    super.dispose();
  }

  Future<void> _loadExistingUser() async {
    final userResult = await AuthDependencies.getCurrentUser().call();
    final authUser = userResult.valueOrNull;
    final userId = authUser?.id;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoadingInitial = false);
      return;
    }

    final result = await ProfileDependencies.getUserProfile().call(
      userId: userId,
    );
    final profile = result.valueOrNull;

    if (result.isSuccess && profile != null) {
      if (_selectedRole == null && profile.role.trim().isNotEmpty) {
        _selectedRole = profile.role.trim();
      }
      _usernameController.text = (profile.username ?? '').toString();
      _fullNameController.text = (profile.name).toString();
      _emailController.text = (profile.email ?? authUser?.email ?? '').toString();
      _phoneController.text =
          (profile.phone ?? authUser?.phoneNumber ?? '').toString();
      final birthYearRaw = profile.birthYear;
      if (birthYearRaw != null && birthYearRaw.toString().isNotEmpty) {
        _birthYearController.text = birthYearRaw.toString();
      }
      _selectedGender = profile.gender;
      final govRaw = profile.governorate;
      if (govRaw.isNotEmpty &&
          AppConstants.iraqiGovernoratesAr.contains(govRaw)) {
        _selectedGovernorate = govRaw;
      } else {
        _selectedGovernorate = null;
      }
      _over18Confirmed = profile.over18Confirmed;
      if (_usernameController.text.trim().isNotEmpty) {
        _usernameAvailable = true;
      }
    } else {
      _emailController.text = (authUser?.email ?? '').toString();
      _phoneController.text = (authUser?.phoneNumber ?? '').toString();
    }

    if (!mounted) return;
    setState(() => _isLoadingInitial = false);
  }

  Future<void> _checkUsernameAvailability(String rawUsername) async {
    final username = rawUsername.trim().toLowerCase();
    if (username.length < 2) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError = null;
      });
      return;
    }

    if (_isUsernameForbidden(username)) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError = 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù…Ø­Ø¬ÙˆØ²';
      });
      return;
    }

    if (!_isUsernameFormatValid(username)) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError =
            'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ÙŠØ¬Ø¨ Ø£Ù† ÙŠØ¨Ø¯Ø£ Ø¨Ø­Ø±Ù ÙˆÙŠØ­ØªÙˆÙŠ Ø­Ø±ÙˆÙØ§Ù‹ Ø£Ùˆ Ø£Ø±Ù‚Ø§Ù…Ø§Ù‹ ÙÙ‚Ø·';
      });
      return;
    }

    setState(() => _isCheckingUsername = true);

    try {
      final result = await ProfileDependencies.checkUsernameAvailability().call(
        username,
      );
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Check failed');
      }
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = result.valueOrNull ?? false;
        _usernameError = (_usernameAvailable) ? null : 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ØºÙŠØ± Ù…ØªØ§Ø­';
      });
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailable = false;
        _usernameError = 'ØªØ¹Ø°Ø± Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ø­Ø¯Ø« Ø®Ø·Ø£ Ø£Ø«Ù†Ø§Ø¡ ÙØ­Øµ Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…')),
        );
      }
    }
  }

  Future<void> _generateSuggestions() async {
    setState(() {
      _isSuggesting = true;
      _suggestions = [];
    });

    final candidates = _buildUsernameCandidates();
    final unique = <String>{};
    final results = <String>[];

    for (final candidate in candidates) {
      final normalized = _normalizeUsername(candidate);
      if (normalized.isEmpty) continue;
      if (_isUsernameForbidden(normalized)) continue;
      if (!_isUsernameFormatValid(normalized)) continue;
      if (unique.contains(normalized)) continue;
      unique.add(normalized);

      final check = await ProfileDependencies.checkUsernameAvailability().call(
        normalized,
      );
      if (check.isSuccess && (check.valueOrNull ?? false)) {
        results.add(normalized);
      }
      if (results.length >= 6) break;
    }

    if (mounted) {
      setState(() {
        _isSuggesting = false;
        _suggestions = results;
      });
    }
  }

  List<String> _buildUsernameCandidates() {
    final name = _fullNameController.text.trim().toLowerCase();
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();
    final selectedRole = (_selectedRole ?? '').trim();

    final emailBase = email.contains('@') ? email.split('@').first : '';
    final phoneSuffix =
        phone.replaceAll(RegExp(r'\D'), '').replaceAll(RegExp(r'^0+'), '');
    final phoneTail =
        phoneSuffix.length >= 4 ? phoneSuffix.substring(phoneSuffix.length - 4) : '';

    final bases = <String>{
      if (name.isNotEmpty) name,
      if (emailBase.isNotEmpty) emailBase,
      if (phoneTail.isNotEmpty) 'user$phoneTail',
      if (selectedRole == AppConstants.rolePhotographer) 'photo',
      if (selectedRole == AppConstants.roleCustomer) 'client',
      'user',
    };

    final candidates = <String>[];
    for (final base in bases) {
      candidates.add(base);
      for (var i = 1; i <= 3; i++) {
        candidates.add('$base$i');
      }
      if (phoneTail.isNotEmpty) {
        candidates.add('${base}_$phoneTail');
      }
    }
    return candidates;
  }

  String _normalizeUsername(String raw) {
    var normalized = raw.toLowerCase();
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalized.isEmpty) return '';
    if (!RegExp(r'^[a-z]').hasMatch(normalized)) {
      normalized = 'u$normalized';
    }
    return normalized;
  }

  bool _isUsernameForbidden(String username) {
    if (_reservedUsernames.contains(username)) return true;
    if (username.startsWith('admin')) return true;
    if (username.startsWith('support')) return true;
    if (username.startsWith('system')) return true;
    return false;
  }

  bool _isUsernameFormatValid(String username) {
    final regex = RegExp(r'^[a-z][a-z0-9]*$');
    return regex.hasMatch(username) && username.length >= 2;
  }

  Future<void> _saveAndContinue() async {
    final localizations = AppLocalizations.of(context);
    final selectedRole = (_selectedRole ?? '').trim();
    if (selectedRole.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.chooseRole)));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_usernameError != null && _usernameError!.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_usernameError!)));
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ø§Ø®ØªØ± Ø§Ù„Ø¬Ù†Ø³ Ù…Ù† ÙØ¶Ù„Ùƒ')));
      return;
    }
    if (_selectedGovernorate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ø§Ø®ØªØ± Ø§Ù„Ù…Ø­Ø§ÙØ¸Ø© Ù…Ù† ÙØ¶Ù„Ùƒ')));
      return;
    }
    if (!_over18Confirmed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ÙŠØ¬Ø¨ ØªØ£ÙƒÙŠØ¯ Ø£Ù†Ùƒ ÙÙˆÙ‚ 18 Ø³Ù†Ø©')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('Ù„Ù… ÙŠØªÙ… Ø§Ù„Ø¹Ø«ÙˆØ± Ø¹Ù„Ù‰ Ù…Ø³ØªØ®Ø¯Ù… Ù…Ø³Ø¬Ù„ Ø­Ø§Ù„ÙŠØ§Ù‹');
      }

      final username = _usernameController.text.trim().toLowerCase();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final birthYear = int.tryParse(_birthYearController.text.trim());
      final age = birthYear != null ? DateTime.now().year - birthYear : null;

      final data = BasicInfoData(
        role: selectedRole,
        name: _fullNameController.text.trim(),
        username: username,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
        governorate: _selectedGovernorate!,
        gender: _selectedGender,
        birthYear: birthYear,
        age: age,
        over18Confirmed: _over18Confirmed,
        profileCompleted: true,
      );
      final result = await ProfileDependencies.saveBasicInfo().call(
        userId: userId,
        data: data,
      );
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Save failed');
      }
      AppRouter.invalidateProfileCache(userId);

      setState(() => _isLoading = false);

      if (!mounted) return;
      AppRouter.goToHome(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ø­Ø¯Ø« Ø®Ø·Ø£ Ø£Ø«Ù†Ø§Ø¡ Ø§Ù„Ø­ÙØ¸')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context);
    final roleLocked = widget.userRole.trim().isNotEmpty;
    final selectedRole = (_selectedRole ?? '').trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ø§Ù„Ù…Ø¹Ù„ÙˆÙ…Ø§Øª Ø§Ù„Ø£Ø³Ø§Ø³ÙŠØ©'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                localizations.chooseRole,
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              IgnorePointer(
                ignoring: roleLocked,
                child: Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        icon: Icons.person,
                        label: localizations.customer,
                        isSelected:
                            selectedRole == AppConstants.roleCustomer,
                        onTap: () => setState(
                          () => _selectedRole = AppConstants.roleCustomer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        icon: Icons.camera_alt,
                        label: localizations.photographer,
                        isSelected:
                            selectedRole == AppConstants.rolePhotographer,
                        onTap: () => setState(
                          () => _selectedRole = AppConstants.rolePhotographer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… (Username)',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _usernameController,
                hint: 'Ù…Ø«Ø§Ù„: ahmedphoto23',
                prefixIcon: Icons.person_outline,
                suffixIcon: _isCheckingUsername
                    ? null
                    : _usernameAvailable
                    ? Icons.check_circle
                    : null,
                onChanged: (value) {
                  final normalized = value.trim().toLowerCase();
                  if (normalized != value) {
                    _usernameController
                      ..text = normalized
                      ..selection = TextSelection.collapsed(
                        offset: normalized.length,
                      );
                  }
                  setState(() => _usernameError = null);
                  _usernameDebouncer(
                    () => _checkUsernameAvailability(normalized),
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ø§Ù„Ø±Ø¬Ø§Ø¡ Ø¥Ø¯Ø®Ø§Ù„ Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù…';
                  }
                  final normalized = value.trim().toLowerCase();
                  if (_isUsernameForbidden(normalized)) {
                    return 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù…Ø­Ø¬ÙˆØ²';
                  }
                  if (!_isUsernameFormatValid(normalized)) {
                    return 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ÙŠØ¬Ø¨ Ø£Ù† ÙŠØ¨Ø¯Ø£ Ø¨Ø­Ø±Ù ÙˆÙŠØ­ØªÙˆÙŠ Ø­Ø±ÙˆÙØ§Ù‹ Ø£Ùˆ Ø£Ø±Ù‚Ø§Ù…Ø§Ù‹ ÙÙ‚Ø· (Ø¨Ø¯ÙˆÙ† Ù…Ø³Ø§ÙØ§Øª)';
                  }
                  if (normalized.length < 2) {
                    return 'ÙŠØ¬Ø¨ Ø£Ù„Ø§ ÙŠÙ‚Ù„ Ø¹Ù† Ø­Ø±ÙÙŠÙ†';
                  }
                  if (!_usernameAvailable && !_isCheckingUsername) {
                    return 'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ØºÙŠØ± Ù…ØªØ§Ø­';
                  }
                  if (_usernameError != null && _usernameError!.isNotEmpty) {
                    return _usernameError;
                  }
                  return null;
                },
              ),
              if (_isCheckingUsername)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Ø¬Ø§Ø±Ù Ø§Ù„ØªØ­Ù‚Ù‚...',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (_usernameAvailable && !_isCheckingUsername)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: scheme.tertiary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ù…ØªØ§Ø­',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_usernameAvailable &&
                  !_isCheckingUsername &&
                  _usernameController.text.length >= 2)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error, size: 16, color: scheme.error),
                      SizedBox(width: 4),
                      Text(
                        'Ø§Ø³Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ØºÙŠØ± Ù…ØªØ§Ø­',
                        style: TextStyle(fontSize: 12, color: scheme.error),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ø§Ù‚ØªØ±Ø§Ø­Ø§Øª Ø§Ø³Ù… Ù…Ø³ØªØ®Ø¯Ù…',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: _isSuggesting ? null : _generateSuggestions,
                    child: Text(_isSuggesting ? 'Ø¬Ø§Ø±ÙŠ...' : 'Ø§Ù‚ØªØ±Ø§Ø­Ø§Øª'),
                  ),
                ],
              ),
              if (_suggestions.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions
                      .map(
                        (suggestion) => ActionChip(
                          label: Text(suggestion),
                          onPressed: () {
                            _usernameController.text = suggestion;
                            _usernameController.selection =
                                TextSelection.collapsed(
                              offset: suggestion.length,
                            );
                            _checkUsernameAvailability(suggestion);
                          },
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 20),

              Text(
                'Ø±Ù‚Ù… Ø§Ù„Ù‡Ø§ØªÙ',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _phoneController,
                hint: 'Ø±Ù‚Ù… Ø§Ù„Ù‡Ø§ØªÙ',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                enabled: false,
              ),
              const SizedBox(height: 20),

              Text(
                'Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ (Ø§Ø®ØªÙŠØ§Ø±ÙŠ)',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _emailController,
                hint: 'example@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }
                  final normalized = value.trim();
                  if (!normalized.contains('@') || !normalized.contains('.')) {
                    return 'ØµÙŠØºØ© Ø§Ù„Ø¨Ø±ÙŠØ¯ Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠ ØºÙŠØ± ØµØ­ÙŠØ­Ø©';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Ø§Ù„Ø§Ø³Ù… Ø§Ù„ÙƒØ§Ù…Ù„',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _fullNameController,
                hint: 'Ø§ÙƒØªØ¨ Ø§Ø³Ù…Ùƒ Ø§Ù„ÙƒØ§Ù…Ù„',
                prefixIcon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ø§Ù„Ø§Ø³Ù… Ø§Ù„ÙƒØ§Ù…Ù„ Ù…Ø·Ù„ÙˆØ¨';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Ø§Ù„Ø¬Ù†Ø³',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GenderOption(
                      icon: Icons.male,
                      label: 'Ø°ÙƒØ±',
                      isSelected: _selectedGender == 'male',
                      onTap: () => setState(() => _selectedGender = 'male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderOption(
                      icon: Icons.female,
                      label: 'Ø£Ù†Ø«Ù‰',
                      isSelected: _selectedGender == 'female',
                      onTap: () => setState(() => _selectedGender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Ø³Ù†Ø© Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _birthYearController,
                hint: 'Ù…Ø«Ø§Ù„: 1995',
                prefixIcon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ø§Ù„Ø±Ø¬Ø§Ø¡ Ø¥Ø¯Ø®Ø§Ù„ Ø³Ù†Ø© Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯';
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year - 18) {
                    return 'ÙŠØ¬Ø¨ Ø£Ù† ØªØ´ÙŠØ± Ø³Ù†Ø© Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯ Ø¥Ù„Ù‰ Ø¹Ù…Ø± 18 Ø¹Ø§Ù…Ø§Ù‹ Ø£Ùˆ Ø£ÙƒØ«Ø±';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Ø§Ù„Ù…Ø­Ø§ÙØ¸Ø©',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              AppDropdownField<String>(
                initialValue: _selectedGovernorate,
                hint: 'Ø§Ø®ØªØ± Ø§Ù„Ù…Ø­Ø§ÙØ¸Ø©',
                prefixIcon: Icons.location_on,
                items: AppConstants.iraqiGovernoratesAr.map((gov) {
                  return DropdownMenuItem(value: gov, child: Text(gov));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedGovernorate = value),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _over18Confirmed,
                      onChanged: (value) {
                        setState(() => _over18Confirmed = value ?? false);
                      },
                      activeColor: scheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Ø£Ø¤ÙƒØ¯ Ø£Ù† Ø¹Ù…Ø±ÙŠ ÙÙˆÙ‚ 18 Ø³Ù†Ø©',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CTAButton(
                text: 'Ù…ØªØ§Ø¨Ø¹Ø©',
                onPressed: _saveAndContinue,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.1)
              : scheme.surface,
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: isSelected ? scheme.primary : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
