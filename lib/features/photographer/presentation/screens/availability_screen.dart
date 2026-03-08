import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  static const String _prefsKey = 'photographer_availability_v1';

  final List<_DayAvailability> _days = _defaultDays();
  bool _allowSameDayBookings = false;
  double _travelRadiusKm = 25;
  double _minBookingPrice = 50000;
  double _deliveryDays = 3;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _allowSameDayBookings =
              decoded['allowSameDayBookings'] as bool? ?? _allowSameDayBookings;
          _travelRadiusKm =
              (decoded['travelRadiusKm'] as num?)?.toDouble() ?? _travelRadiusKm;
          _minBookingPrice =
              (decoded['minBookingPrice'] as num?)?.toDouble() ?? _minBookingPrice;
          _deliveryDays =
              (decoded['deliveryDays'] as num?)?.toDouble() ?? _deliveryDays;

          final days = decoded['days'];
          if (days is List) {
            for (var index = 0; index < days.length && index < _days.length; index++) {
              final item = days[index];
              if (item is Map) {
                _days[index] = _DayAvailability.fromJson(
                  Map<String, dynamic>.from(item),
                );
              }
            }
          }
        }
      } catch (_) {
        // Ignore malformed cached settings and fall back to defaults.
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'allowSameDayBookings': _allowSameDayBookings,
      'travelRadiusKm': _travelRadiusKm.round(),
      'minBookingPrice': _minBookingPrice.round(),
      'deliveryDays': _deliveryDays.round(),
      'days': _days.map((day) => day.toJson()).toList(),
    });
    await prefs.setString(_prefsKey, payload);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _localizedText(
            ar: 'تم حفظ إعدادات التوفر محليًا',
            en: 'Availability saved locally',
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickTime({
    required int dayIndex,
    required bool isStart,
  }) async {
    final day = _days[dayIndex];
    final initialMinutes = isStart ? day.startMinutes : day.endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeFromMinutes(initialMinutes),
    );

    if (picked == null || !mounted) return;

    setState(() {
      final pickedMinutes = picked.hour * 60 + picked.minute;
      if (isStart) {
        day.startMinutes = pickedMinutes;
        if (day.endMinutes <= day.startMinutes + 30) {
          day.endMinutes = ((day.startMinutes + 60).clamp(60, 1439) as num).toInt();
        }
      } else {
        day.endMinutes = pickedMinutes;
        if (day.endMinutes <= day.startMinutes + 30) {
          day.startMinutes = ((day.endMinutes - 60).clamp(0, 1379) as num).toInt();
        }
      }
    });
  }

  String _localizedText({
    required String ar,
    required String en,
  }) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'ar' ? ar : en;
  }

  String _dayLabel(int index) {
    const arabicDays = <String>[
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    const englishDays = <String>[
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'ar' ? arabicDays[index] : englishDays[index];
  }

  int get _todayIndex => DateTime.now().weekday % 7;

  String _formatMinutes(int minutes) {
    final materialLocalizations = MaterialLocalizations.of(context);
    return materialLocalizations.formatTimeOfDay(
      _timeFromMinutes(minutes),
      alwaysUse24HourFormat: true,
    );
  }

  TimeOfDay _timeFromMinutes(int minutes) {
    return TimeOfDay(
      hour: minutes ~/ 60,
      minute: minutes % 60,
    );
  }

  String _todaySummary() {
    final today = _days[_todayIndex];
    if (!today.isEnabled) {
      return _localizedText(ar: 'مغلق اليوم', en: 'Closed today');
    }

    return '${_formatMinutes(today.startMinutes)} - ${_formatMinutes(today.endMinutes)}';
  }

  Widget _buildTodayCard(ThemeData theme, AppLocalizations localizations) {
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.today_outlined, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.todaySchedule,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todaySummary(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(ThemeData theme, AppLocalizations localizations) {
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.manageSlots,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _allowSameDayBookings,
              title: Text(
                _localizedText(
                  ar: 'السماح بالحجز في نفس اليوم',
                  en: 'Allow same-day bookings',
                ),
              ),
              subtitle: Text(
                _localizedText(
                  ar: 'مفيد للحجوزات السريعة والطارئة',
                  en: 'Useful for urgent and last-minute bookings',
                ),
              ),
              onChanged: (value) {
                setState(() => _allowSameDayBookings = value);
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.minPrice}: ${_minBookingPrice.round()} IQD',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _minBookingPrice,
              min: 0,
              max: 500000,
              divisions: 50,
              label: '${_minBookingPrice.round()} IQD',
              onChanged: (value) {
                setState(() => _minBookingPrice = value);
              },
            ),
            Text(
              '${localizations.deliveryDays}: ${_deliveryDays.round()}',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _deliveryDays,
              min: 1,
              max: 30,
              divisions: 29,
              label: _deliveryDays.round().toString(),
              onChanged: (value) {
                setState(() => _deliveryDays = value);
              },
            ),
            Text(
              _localizedText(
                ar: 'نطاق التنقل: ${_travelRadiusKm.round()} كم',
                en: 'Travel radius: ${_travelRadiusKm.round()} km',
              ),
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Slider(
              value: _travelRadiusKm,
              min: 5,
              max: 200,
              divisions: 39,
              label: '${_travelRadiusKm.round()} km',
              onChanged: (value) {
                setState(() => _travelRadiusKm = value);
              },
            ),
            Text(
              _localizedText(
                ar: 'هذه الإعدادات محفوظة محليًا حاليًا إلى حين ربطها بالباكند.',
                en: 'These settings are currently saved locally until the backend is wired.',
              ),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(ThemeData theme, int index) {
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final day = _days[index];

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dayLabel(index),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.isEnabled
                            ? '${_formatMinutes(day.startMinutes)} - ${_formatMinutes(day.endMinutes)}'
                            : _localizedText(ar: 'مغلق', en: 'Closed'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  key: Key('availability-day-toggle-$index'),
                  value: day.isEnabled,
                  onChanged: (value) {
                    setState(() => day.isEnabled = value);
                  },
                ),
              ],
            ),
            if (day.isEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(dayIndex: index, isStart: true),
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(
                        _localizedText(
                          ar: 'من ${_formatMinutes(day.startMinutes)}',
                          en: 'From ${_formatMinutes(day.startMinutes)}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(dayIndex: index, isStart: false),
                      icon: const Icon(Icons.schedule_send_outlined),
                      label: Text(
                        _localizedText(
                          ar: 'إلى ${_formatMinutes(day.endMinutes)}',
                          en: 'To ${_formatMinutes(day.endMinutes)}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.availability)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Icon(Icons.calendar_month, size: 64, color: scheme.primary),
                const SizedBox(height: 16),
                Text(
                  localizations.manageSlots,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.weeklyTemplate,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTodayCard(theme, localizations),
                const SizedBox(height: 16),
                _buildPreferencesCard(theme, localizations),
                const SizedBox(height: 16),
                Text(
                  localizations.weeklyTemplate,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < _days.length; index++)
                  _buildDayCard(theme, index),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('availability-save-button'),
                  onPressed: _isSaving ? null : _saveAvailability,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? '...' : localizations.save),
                ),
              ],
            ),
    );
  }
}

class _DayAvailability {
  bool isEnabled;
  int startMinutes;
  int endMinutes;

  _DayAvailability({
    required this.isEnabled,
    required this.startMinutes,
    required this.endMinutes,
  });

  factory _DayAvailability.fromJson(Map<String, dynamic> json) {
    return _DayAvailability(
      isEnabled: json['isEnabled'] as bool? ?? false,
      startMinutes: json['startMinutes'] as int? ?? 540,
      endMinutes: json['endMinutes'] as int? ?? 1020,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
    };
  }
}

List<_DayAvailability> _defaultDays() {
  return <_DayAvailability>[
    _DayAvailability(isEnabled: false, startMinutes: 540, endMinutes: 1020),
    _DayAvailability(isEnabled: true, startMinutes: 540, endMinutes: 1020),
    _DayAvailability(isEnabled: true, startMinutes: 540, endMinutes: 1020),
    _DayAvailability(isEnabled: true, startMinutes: 540, endMinutes: 1020),
    _DayAvailability(isEnabled: true, startMinutes: 540, endMinutes: 1020),
    _DayAvailability(isEnabled: true, startMinutes: 540, endMinutes: 1020),
    _DayAvailability(isEnabled: false, startMinutes: 540, endMinutes: 1020),
  ];
}
