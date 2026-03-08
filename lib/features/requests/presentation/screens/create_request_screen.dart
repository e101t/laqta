import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/notifications/domain/entities/notification_model.dart';
import 'package:luqta/features/notifications/notifications_dependencies.dart';
import 'package:luqta/features/requests/domain/entities/photo_request.dart';
import 'package:luqta/features/requests/domain/entities/request_deliverables.dart';
import 'package:luqta/features/requests/domain/utils/request_validation.dart';
import 'package:luqta/features/requests/presentation/screens/select_location_screen.dart';
import 'package:luqta/features/requests/requests_dependencies.dart';
import 'package:luqta/features/search/search_dependencies.dart';

class CreateRequestScreen extends StatefulWidget {
  final PhotoRequest? initialRequest;
  final String? prefillType;
  final String? prefillStyle;
  final String? prefillNotes;
  final List<String> prefillReferenceImages;
  final String? prefillSelectedPhotographerId;
  final String? prefillGovernorate;
  final DateTime? prefillDate;
  final TimeOfDay? prefillTime;
  final void Function(String requestId)? onRequestSubmitted;
  final Future<LocationSelectionResult?> Function(
    BuildContext context,
    LatLng? currentPosition,
    String? currentLabel,
    String? governorate,
  )?
  locationPicker;

  const CreateRequestScreen({
    super.key,
    this.initialRequest,
    this.prefillType,
    this.prefillStyle,
    this.prefillNotes,
    this.prefillReferenceImages = const [],
    this.prefillSelectedPhotographerId,
    this.prefillGovernorate,
    this.prefillDate,
    this.prefillTime,
    this.onRequestSubmitted,
    this.locationPicker,
  });

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _budgetMinController = TextEditingController();
  final TextEditingController _budgetMaxController = TextEditingController();
  final TextEditingController _photosCountController = TextEditingController();
  final TextEditingController _videoMinutesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedType;
  String? _selectedStyle;
  String? _selectedGovernorate;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationHours = 2;
  bool _includesEditing = false;
  bool _includesVideo = false;

  LatLng? _selectedLatLng;
  String? _locationLabel;

  final List<XFile> _referenceFiles = [];
  final List<String> _existingReferenceUrls = [];
  bool _isSubmitting = false;
  late final String _requestId;
  String? _preferredPhotographerId;

  bool get _isEditing => widget.initialRequest != null;

  static const List<String> _styles = [
    'Classic',
    'Cinematic',
    'Documentary',
    'Studio',
    'Outdoor',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _photosCountController.dispose();
    _videoMinutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRequest;
    if (initial != null) {
      _requestId = initial.id;
      _selectedType = initial.type;
      _selectedStyle = initial.style;
      _selectedGovernorate = initial.governorate;
      _selectedDate = DateTime.tryParse(initial.date);
      _selectedTime = _parseTime(initial.time);
      _durationHours = initial.durationHours;
      _includesEditing = initial.deliverables.includesEditing;
      _includesVideo = initial.deliverables.includesVideo;
      _addressController.text = initial.address ?? '';
      _budgetMinController.text = initial.budgetMin?.toString() ?? '';
      _budgetMaxController.text = initial.budgetMax?.toString() ?? '';
      _photosCountController.text =
          initial.deliverables.photosCount?.toString() ?? '';
      _videoMinutesController.text =
          initial.deliverables.videoMinutes?.toString() ?? '';
      _notesController.text = initial.notes ?? '';
      _existingReferenceUrls.addAll(initial.referenceImages);
      if (initial.latitude != null && initial.longitude != null) {
        _selectedLatLng = LatLng(initial.latitude!, initial.longitude!);
      }
      _locationLabel = initial.locationLabel;
      _preferredPhotographerId = initial.selectedPhotographerId;
    } else {
      _requestId = RequestsDependencies.generateRequestId().call();
      _selectedType = widget.prefillType;
      _selectedStyle = widget.prefillStyle;
      _selectedGovernorate = widget.prefillGovernorate;
      _selectedDate = widget.prefillDate;
      _selectedTime = widget.prefillTime;
      if (widget.prefillNotes != null && widget.prefillNotes!.isNotEmpty) {
        _notesController.text = widget.prefillNotes!;
      }
      if (widget.prefillReferenceImages.isNotEmpty) {
        _existingReferenceUrls.addAll(widget.prefillReferenceImages);
      }
      _preferredPhotographerId = widget.prefillSelectedPhotographerId;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<LocationSelectionResult?> _openLocationPicker() {
    final picker = widget.locationPicker;
    if (picker != null) {
      return picker(
        context,
        _selectedLatLng,
        _locationLabel,
        _selectedGovernorate,
      );
    }
    return Navigator.of(context).push<LocationSelectionResult>(
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(
          initialPosition: _selectedLatLng,
          initialLabel: _locationLabel,
          governorate: _selectedGovernorate,
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await _openLocationPicker();
    if (!mounted) return;
    if (result == null) return;
    setState(() {
      _selectedLatLng = result.position;
      _locationLabel = result.label;
    });
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _addReferenceImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (!mounted) return;
    if (files.isEmpty) return;

    setState(() {
      for (final file in files) {
        if (_referenceFiles.length + _existingReferenceUrls.length >= 6) break;
        _referenceFiles.add(file);
      }
    });
  }

  void _removeExistingReference(int index) {
    setState(() => _existingReferenceUrls.removeAt(index));
  }

  void _removeNewReference(int index) {
    setState(() => _referenceFiles.removeAt(index));
  }

  bool _canSubmit() {
    return _selectedType != null &&
        _selectedGovernorate != null &&
        _selectedDate != null &&
        _selectedTime != null;
  }

  Future<void> _notifyPhotographers({
    required String requestId,
    required String requestType,
    required String governorate,
  }) async {
    try {
      final searchResult = await SearchDependencies.searchPhotographers().call(
        query: governorate,
      );
      final photographers = searchResult.valueOrNull ?? const [];

      for (final photographer in photographers) {
        if (photographer.governorate != governorate) {
          continue;
        }
        final notification = NotificationModel(
          notificationId: '',
          userId: photographer.id,
          title: 'New request near you',
          body: '$requestType request in $governorate.',
          type: 'request',
          data: {'requestId': requestId},
          createdAt: DateTime.now(),
        );
        await NotificationsDependencies.createNotification().call(notification);
      }
    } catch (_) {
      // Best-effort notifications.
    }
  }

  Map<String, dynamic> _buildLocationPayload() {
    final lat = _selectedLatLng?.latitude;
    final lng = _selectedLatLng?.longitude;
    final label = _locationLabel;
    final hasLocation =
        lat != null || lng != null || (label != null && label.isNotEmpty);
    return {
      'latitude': lat,
      'longitude': lng,
      'locationLabel': label,
      'location': hasLocation ? {'lat': lat, 'lng': lng, 'label': label} : null,
    };
  }

  Future<void> _submitRequest({required bool asDraft}) async {
    if (!_canSubmit()) return;
    final localizations = AppLocalizations.of(context);

    setState(() => _isSubmitting = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw StateError('Missing user');
      }

      final budgetMin = double.tryParse(_budgetMinController.text.trim());
      final budgetMax = double.tryParse(_budgetMaxController.text.trim());
      final photosCount = int.tryParse(_photosCountController.text.trim());
      final videoMinutes = int.tryParse(_videoMinutesController.text.trim());
      final validationError = RequestValidation.validate(
        date: _selectedDate,
        time: _selectedTime,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        latitude: _selectedLatLng?.latitude,
        longitude: _selectedLatLng?.longitude,
        label: _locationLabel,
      );
      if (validationError != null) {
        if (mounted) {
          final message = switch (validationError) {
            RequestValidationError.dateTime => localizations.invalidDateTime,
            RequestValidationError.budget => localizations.invalidBudgetRange,
            RequestValidationError.location => localizations.invalidLocation,
          };
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
        return;
      }

      final deliverables = RequestDeliverables(
        photosCount: photosCount,
        videoMinutes: videoMinutes,
        includesEditing: _includesEditing,
        includesVideo: _includesVideo,
      );

      final formattedDate =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      final address = _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final shouldPublish = !_isEditing
          ? !asDraft
          : (widget.initialRequest!.status == 'draft' && !asDraft);

      if (_isEditing) {
        final locationPayload = _buildLocationPayload();
        final updates = <String, dynamic>{
          'type': _selectedType!,
          'date': formattedDate,
          'time': formattedTime,
          'governorate': _selectedGovernorate!,
          'address': address,
          'budgetMin': budgetMin,
          'budgetMax': budgetMax,
          'duration': _durationHours,
          'style': _selectedStyle,
          'deliverables': {
            'photosCount': photosCount,
            'videoMinutes': videoMinutes,
            'includesEditing': _includesEditing,
            'includesVideo': _includesVideo,
            'notes': null,
          },
          'notes': notes,
          ...locationPayload,
        };

        if (widget.initialRequest!.status == 'draft') {
          updates['status'] = shouldPublish ? 'awaiting_offers' : 'draft';
          updates['expiresAt'] = shouldPublish
              ? DateTime.now().add(const Duration(hours: 48))
              : null;
        }

        final result = await RequestsDependencies.updateRequest().call(
          requestId: _requestId,
          updates: updates,
        );
        if (!result.isSuccess) {
          throw StateError('Failed to update request');
        }
      } else {
        final request = PhotoRequest(
          id: _requestId,
          clientId: userId,
          type: _selectedType!,
          date: formattedDate,
          time: formattedTime,
          governorate: _selectedGovernorate!,
          address: address,
          budgetMin: budgetMin,
          budgetMax: budgetMax,
          durationHours: _durationHours,
          style: _selectedStyle,
          deliverables: deliverables,
          notes: notes,
          referenceImages: const [],
          status: asDraft ? 'draft' : 'awaiting_offers',
          offersCount: 0,
          selectedOfferId: null,
          selectedPhotographerId: _preferredPhotographerId,
          expiresAt: asDraft
              ? null
              : DateTime.now().add(const Duration(hours: 48)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          latitude: _selectedLatLng?.latitude,
          longitude: _selectedLatLng?.longitude,
          locationLabel: _locationLabel,
        );

        final result = await RequestsDependencies.createRequest().call(request);
        if (!result.isSuccess) {
          throw StateError('Failed to create request');
        }
      }

      if ((!_isEditing && !asDraft) || (_isEditing && shouldPublish)) {
        await _notifyPhotographers(
          requestId: _requestId,
          requestType: _selectedType!,
          governorate: _selectedGovernorate!,
        );
      }

      final referenceUrls = List<String>.from(_existingReferenceUrls);
      if (_referenceFiles.isNotEmpty) {
        for (final file in _referenceFiles) {
          final uploadResult =
              await RequestsDependencies.uploadRequestReference().call(
                requestId: _requestId,
                filePath: file.path,
              );
          if (uploadResult.isSuccess && uploadResult.valueOrNull != null) {
            referenceUrls.add(uploadResult.valueOrNull!);
          }
        }
      }
      if (referenceUrls.isNotEmpty) {
        await RequestsDependencies.updateRequest().call(
          requestId: _requestId,
          updates: {'referenceImages': referenceUrls},
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? localizations.requestUpdated
                  : (asDraft
                        ? localizations.draftSaved
                        : localizations.requestPublished),
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        if (widget.onRequestSubmitted != null) {
          widget.onRequestSubmitted!(_requestId);
        } else {
          AppRouter.goToRequestDetails(context, _requestId);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.requestSubmitFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? localizations.editRequest : localizations.createRequest,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.requestDetails,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              label: localizations.photographyType,
              initialValue: _selectedType,
              items: AppConstants.specialtiesEn
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              label: localizations.styleLabel,
              initialValue: _selectedStyle,
              items: _styles
                  .map(
                    (style) => DropdownMenuItem<String>(
                      value: style,
                      child: Text(style),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedStyle = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: localizations.dateLabel,
                    hint: _selectedDate == null
                        ? localizations.selectDate
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    readOnly: true,
                    onTap: _selectDate,
                    prefixIcon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: localizations.timeLabel,
                    hint: _selectedTime == null
                        ? localizations.selectTime
                        : _selectedTime!.format(context),
                    readOnly: true,
                    onTap: _selectTime,
                    prefixIcon: Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              label: localizations.governorate,
              initialValue: _selectedGovernorate,
              items: AppConstants.iraqiGovernoratesEn
                  .map(
                    (gov) =>
                        DropdownMenuItem<String>(value: gov, child: Text(gov)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedGovernorate = value),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _addressController,
              label: localizations.addressOptional,
              hint: localizations.addressHint,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.map),
              label: Text(
                _selectedLatLng == null
                    ? localizations.selectLocationOnMap
                    : localizations.locationSelected,
              ),
            ),
            if (_selectedLatLng != null) ...[
              const SizedBox(height: 8),
              Text(
                _locationLabel ??
                    'Lat ${_selectedLatLng!.latitude.toStringAsFixed(4)}, '
                        'Lng ${_selectedLatLng!.longitude.toStringAsFixed(4)}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '${localizations.budget} (${AppConstants.currencyIQD})',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _budgetMinController,
                    label: localizations.minLabel,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _budgetMaxController,
                    label: localizations.maxLabel,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${localizations.duration}: $_durationHours ${localizations.hours}',
              style: textTheme.titleMedium,
            ),
            Slider(
              value: _durationHours.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              onChanged: (value) =>
                  setState(() => _durationHours = value.toInt()),
            ),
            const SizedBox(height: 16),
            Text(localizations.deliverables, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _photosCountController,
                    label: localizations.photosCount,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _videoMinutesController,
                    label: localizations.videoMinutes,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _includesVideo,
              onChanged: (value) => setState(() => _includesVideo = value),
              title: Text(localizations.includeVideo),
            ),
            SwitchListTile(
              value: _includesEditing,
              onChanged: (value) => setState(() => _includesEditing = value),
              title: Text(localizations.includeEditing),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: localizations.additionalNotes,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _addReferenceImages,
                    icon: const Icon(Icons.image),
                    label: Text(localizations.addReferenceImages),
                  ),
                ),
              ],
            ),
            if (_existingReferenceUrls.isNotEmpty ||
                _referenceFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index < _existingReferenceUrls.length) {
                      final url = _existingReferenceUrls[index];
                      return _ReferenceThumbnail(
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        onRemove: () => _removeExistingReference(index),
                      );
                    }
                    final file =
                        _referenceFiles[index - _existingReferenceUrls.length];
                    return _ReferenceThumbnail(
                      child: Image.file(
                        File(file.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      onRemove: () => _removeNewReference(
                        index - _existingReferenceUrls.length,
                      ),
                    );
                  },
                  separatorBuilder: (context, _) => const SizedBox(width: 8),
                  itemCount:
                      _existingReferenceUrls.length + _referenceFiles.length,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_isEditing &&
                widget.initialRequest != null &&
                widget.initialRequest!.status != 'draft') ...[
              SizedBox(
                width: double.infinity,
                child: CTAButton(
                  text: localizations.saveChanges,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting
                      ? null
                      : () => _submitRequest(asDraft: false),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitRequest(asDraft: true),
                      child: Text(localizations.saveDraft),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CTAButton(
                      text: localizations.publishRequest,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitRequest(asDraft: false),
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
}

class _ReferenceThumbnail extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _ReferenceThumbnail({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
