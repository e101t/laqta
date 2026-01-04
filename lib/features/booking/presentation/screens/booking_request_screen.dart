import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/core/models/booking_model.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/booking/booking_dependencies.dart';
import 'package:luqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';

class BookingRequestScreen extends StatefulWidget {
  final String photographerId;
  final String photographerName;

  const BookingRequestScreen({
    super.key,
    required this.photographerId,
    required this.photographerName,
  });

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: Date & Time
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Step 2: Session Details
  String? _selectedSpecialty;
  int _duration = 2; // hours
  final TextEditingController _notesController = TextEditingController();

  // Step 3: Location
  String? _selectedGovernorate;
  final TextEditingController _addressController = TextEditingController();

  // Step 4: Pricing
  final double _basePrice = 120000.0;
  double _totalPrice = 120000.0;

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    setState(() {
      _totalPrice = _basePrice * _duration;
    });
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? AppColors.success.withValues(alpha: 0.9)
            : null,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedDate != null && _selectedTime != null;
      case 1:
        return _selectedSpecialty != null;
      case 2:
        return _selectedGovernorate != null &&
            _addressController.text.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;
    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
      _showSnack('الرجاء تسجيل الدخول لإرسال طلب الحجز');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final booking = BookingModel(
        id: BookingDependencies.generateBookingId().call(),
        customerId: userId,
        photographerId: widget.photographerId,
        date:
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
        time:
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        duration: _duration * 60, // Convert hours to minutes
        type: _selectedSpecialty!,
        price: _totalPrice,
        status: 'pending',
        payment: PaymentInfo(),
        location: LocationInfo(
          text: '$_selectedGovernorate, ${_addressController.text}',
        ),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await BookingDependencies.createBooking().call(
        BookingPresentationMapper.toDomain(booking),
      );
      if (!result.isSuccess) {
        throw StateError('Create booking failed');
      }

      if (mounted) {
        _showSnack('تم إرسال طلب الحجز بنجاح 👍', success: true);

        final localizations = AppLocalizations.of(context);

        if (!AppConstants.enablePayments) {
          _showSnack(localizations.paymentsUnavailable);
          Navigator.of(context).pop();
          return;
        }

        // Navigate to payment screen instead of bookings
        Navigator.of(context).pop();
        AppRouter.goToPayment(
          context,
          booking.id,
          booking.price,
          widget.photographerName,
          booking.type,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack('تعذّر إرسال الطلب');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Book ${widget.photographerName}')),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index <= _currentStep;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (index < 3) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Steps Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _currentStep--);
                        },
                        child: Text(localizations.back),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CTAButton(
                      text: _currentStep == 3 ? 'إرسال الطلب' : 'التالي',
                      isLoading: _isSubmitting,
                      onPressed: _canProceedToNextStep() && !_isSubmitting
                          ? () {
                              if (_currentStep == 3) {
                                _submitBooking();
                              } else {
                                setState(() => _currentStep++);
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDateTimeStep();
      case 1:
        return _buildSessionDetailsStep();
      case 2:
        return _buildLocationStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDateTimeStep() {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date & Time', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text(
          'Choose when you want the photography session',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Date Selector
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedDate != null
                    ? AppColors.primary
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _selectedDate != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : localizations.selectDate,
                    style: AppTypography.bodyLarge.copyWith(
                      color: _selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Time Selector
        InkWell(
          onTap: _selectTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedTime != null
                    ? AppColors.primary
                    : AppColors.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: _selectedTime != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : localizations.selectTime,
                    style: AppTypography.bodyLarge.copyWith(
                      color: _selectedTime != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Session Details', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text(
          'Tell us about your photography session',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Specialty Selection
        AppDropdownField<String>(
          label: 'Session Type',
          initialValue: _selectedSpecialty,
          items: AppConstants.specialtiesAr.map((specialty) {
            return DropdownMenuItem<String>(
              value: specialty,
              child: Text(specialty),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedSpecialty = value);
          },
        ),
        const SizedBox(height: 16),

        // Duration Slider
        Text('Duration: $_duration hours', style: AppTypography.h4),
        const SizedBox(height: 8),
        Slider(
          value: _duration.toDouble(),
          min: 1,
          max: 8,
          divisions: 7,
          label: '$_duration hours',
          onChanged: (value) {
            setState(() {
              _duration = value.toInt();
              _calculatePrice();
            });
          },
        ),
        const SizedBox(height: 16),

        // Notes
        AppTextField(
          controller: _notesController,
          label: 'Additional Notes',
          hint: 'Any special requirements or details...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text(
          'Where will the session take place?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Governorate
        AppDropdownField<String>(
          label: localizations.governorate,
          initialValue: _selectedGovernorate,
          items: AppConstants.iraqiGovernoratesAr.map((gov) {
            return DropdownMenuItem<String>(value: gov, child: Text(gov));
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedGovernorate = value);
          },
        ),
        const SizedBox(height: 16),

        // Address
        AppTextField(
          controller: _addressController,
          label: 'Detailed Address',
          hint: 'Street, area, landmarks...',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مراجعة التأكيد', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text(
          'راجع تفاصيل الحجز قبل الإرسال',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow(Icons.person, 'المصوّر', widget.photographerName),
              const Divider(height: 24),
              _buildReviewRow(
                Icons.calendar_today,
                'التاريخ',
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : '-',
              ),
              const Divider(height: 24),
              _buildReviewRow(
                Icons.access_time,
                'الوقت',
                _selectedTime?.format(context) ?? '-',
              ),
              const Divider(height: 24),
              _buildReviewRow(
                Icons.camera_alt,
                'نوع الجلسة',
                _selectedSpecialty ?? '-',
              ),
              const Divider(height: 24),
              _buildReviewRow(Icons.timer, 'المدة', '$_duration ساعة'),
              const Divider(height: 24),
              _buildReviewRow(
                Icons.location_on,
                localizations.governorate,
                _selectedGovernorate ?? '-',
              ),
              if (_addressController.text.isNotEmpty) ...[
                const Divider(height: 24),
                _buildReviewRow(Icons.map, 'العنوان', _addressController.text),
              ],
              if (_notesController.text.isNotEmpty) ...[
                const Divider(height: 24),
                _buildReviewRow(Icons.note, 'ملاحظات', _notesController.text),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Price Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: AppTypography.h3.copyWith(color: AppColors.primary),
              ),
              Text(
                '${_totalPrice.toStringAsFixed(0)} IQD',
                style: AppTypography.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info Note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'سيقوم المصوّر بمراجعة الطلب والرد خلال 24 ساعة. لن يتم أي دفع حتى يتم تأكيد الحجز.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
