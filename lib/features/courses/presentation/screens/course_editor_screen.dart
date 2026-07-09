import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laqta/core/media/image_picker_service.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/courses/course_dependencies.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';
import 'package:laqta/features/courses/presentation/widgets/course_field_card.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';

/// Create/edit screen for a photographer's own course. Pops `true` if the
/// course was saved, so the calling screen knows to refresh its list.
class CourseEditorScreen extends StatefulWidget {
  final String? courseId;

  const CourseEditorScreen({super.key, this.courseId});

  bool get isEditing => courseId != null && courseId!.isNotEmpty;

  @override
  State<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends State<CourseEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController(text: '5');
  final _specialtyController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _locationTextController = TextEditingController();

  String _type = 'in_person';
  final List<String> _specialties = [];
  final List<CourseSession> _sessions = [];
  Course? _existingCourse;
  String? _thumbnailUrl;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingThumbnail = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExisting();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _specialtyController.dispose();
    _meetingLinkController.dispose();
    _locationTextController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    final result = await CourseDependencies.getCourseById().call(
      widget.courseId!,
    );
    if (!mounted) return;
    final course = result.valueOrNull;
    if (course == null) {
      setState(() {
        _isLoading = false;
        _error = AppLocalizations.current.courseLoadFailed;
      });
      return;
    }
    setState(() {
      _existingCourse = course;
      _titleController.text = course.title;
      _descriptionController.text = course.description;
      _priceController.text = course.basePrice.toStringAsFixed(0);
      _capacityController.text = course.capacity.toString();
      _type = course.type;
      _specialties.addAll(course.specialties);
      _sessions.addAll(course.sessions);
      _meetingLinkController.text = course.meetingLink ?? '';
      _locationTextController.text = course.location?.text ?? '';
      _thumbnailUrl = course.thumbnailUrl;
      _isLoading = false;
    });
  }

  Future<void> _pickThumbnail() async {
    final pickedFile = await ImagePickerService().pickImageToTemp(
      source: ImageSource.gallery,
    );
    if (pickedFile == null || !mounted) return;

    setState(() => _isUploadingThumbnail = true);
    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) return;

      final result = await ProfileDependencies.uploadPortfolioImage().call(
        photographerId: userId,
        filePath: pickedFile.path,
      );
      if (!mounted) return;
      if (result.isSuccess && result.valueOrNull != null) {
        setState(() => _thumbnailUrl = result.valueOrNull);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.current.imageUploadFailed)));
      }
    } finally {
      if (mounted) setState(() => _isUploadingThumbnail = false);
    }
  }

  void _addSpecialty() {
    final value = _specialtyController.text.trim();
    if (value.isEmpty || _specialties.contains(value)) return;
    setState(() {
      _specialties.add(value);
      _specialtyController.clear();
    });
  }

  Future<void> _addSession() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute),
    );
    if (end == null || !mounted) return;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.current.endTimeAfterStart)),
      );
      return;
    }

    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    setState(() {
      _sessions.add(
        CourseSession(
          date: dateStr,
          startMinutes: startMinutes,
          endMinutes: endMinutes,
        ),
      );
    });
  }

  String _formatMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      setState(() => _error = AppLocalizations.current.completeCourseTitleDesc);
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      setState(() => _error = AppLocalizations.current.invalidPrice);
      return;
    }
    final capacity = int.tryParse(_capacityController.text.trim());
    if (capacity == null || capacity < 1) {
      setState(() => _error = AppLocalizations.current.invalidSeatsCount);
      return;
    }
    if (_sessions.isEmpty) {
      setState(() => _error = AppLocalizations.current.addAtLeastOneSession);
      return;
    }
    if (_type == 'online' && _meetingLinkController.text.trim().isEmpty) {
      setState(() => _error = AppLocalizations.current.enterOnlineSessionLink);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _isSaving = false;
        _error = AppLocalizations.current.currentUserCheckFailed;
      });
      return;
    }

    final now = DateTime.now();
    final seatsRemaining =
        _existingCourse?.seatsRemaining ?? capacity;

    final course = Course(
      id: _existingCourse?.id ?? '',
      photographerId: _existingCourse?.photographerId ?? userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _type,
      specialties: _specialties,
      basePrice: price,
      currency: 'IQD',
      capacity: capacity,
      seatsRemaining: seatsRemaining,
      sessions: _sessions,
      location: _type == 'in_person'
          ? CourseLocation(text: _locationTextController.text.trim())
          : null,
      meetingLink: _type == 'online'
          ? _meetingLinkController.text.trim()
          : null,
      thumbnailUrl: _thumbnailUrl,
      isPublished: _existingCourse?.isPublished ?? false,
      createdAt: _existingCourse?.createdAt ?? now,
      updatedAt: now,
    );

    final result = widget.isEditing
        ? await CourseDependencies.updateCourse().call(course)
        : await CourseDependencies.createCourse().call(course);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result.isSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = AppLocalizations.current.courseSaveFailed);
    }
  }

  Future<void> _togglePublish() async {
    final course = _existingCourse;
    if (course == null) return;
    final updated = Course(
      id: course.id,
      photographerId: course.photographerId,
      title: course.title,
      description: course.description,
      type: course.type,
      specialties: course.specialties,
      basePrice: course.basePrice,
      currency: course.currency,
      capacity: course.capacity,
      seatsRemaining: course.seatsRemaining,
      sessions: course.sessions,
      location: course.location,
      meetingLink: course.meetingLink,
      thumbnailUrl: course.thumbnailUrl,
      isPublished: !course.isPublished,
      createdAt: course.createdAt,
      updatedAt: DateTime.now(),
    );
    final result = await CourseDependencies.updateCourse().call(updated);
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() => _existingCourse = updated);
    }
  }

  InputDecoration _darkInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      border: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      const LaqtaHeaderBackButton(),
                      const Spacer(),
                      Text(
                        widget.isEditing ? AppLocalizations.current.editCourse : AppLocalizations.current.newCourse,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      if (widget.isEditing && _existingCourse != null)
                        TextButton(
                          onPressed: _togglePublish,
                          child: Text(
                            _existingCourse!.isPublished
                                ? AppLocalizations.current.unpublish
                                : AppLocalizations.current.publish,
                            style: const TextStyle(color: LaqtaColors.accent),
                          ),
                        )
                      else
                        const SizedBox(width: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isUploadingThumbnail ? null : _pickThumbnail,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        color: const Color(0xFF17191F),
                        child: _isUploadingThumbnail
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: LaqtaColors.accent,
                                ),
                              )
                            : _thumbnailUrl == null || _thumbnailUrl!.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: LaqtaColors.accent,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.current.addCourseCover,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  LaqtaRemoteImage(imageUrl: _thumbnailUrl),
                                  PositionedDirectional(
                                    bottom: 8,
                                    end: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.45,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CourseFieldCard(
                    label: AppLocalizations.current.courseTitleLabel,
                    child: TextField(
                      controller: _titleController,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white),
                      decoration: _darkInputDecoration(AppLocalizations.current.courseTitleHint),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CourseFieldCard(
                    label: AppLocalizations.current.descriptionLabel,
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white),
                      decoration: _darkInputDecoration(
                        AppLocalizations.current.courseDescriptionHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(AppLocalizations.current.inPersonLabel),
                          selected: _type == 'in_person',
                          selectedColor: LaqtaColors.accent,
                          backgroundColor: const Color(0xFF191B20),
                          labelStyle: TextStyle(
                            color: _type == 'in_person'
                                ? Colors.black
                                : Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) =>
                              setState(() => _type = 'in_person'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(AppLocalizations.current.onlineLabel),
                          selected: _type == 'online',
                          selectedColor: LaqtaColors.accent,
                          backgroundColor: const Color(0xFF191B20),
                          labelStyle: TextStyle(
                            color: _type == 'online'
                                ? Colors.black
                                : Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) => setState(() => _type = 'online'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_type == 'in_person')
                    CourseFieldCard(
                      label: AppLocalizations.current.courseLocationLabel,
                      child: TextField(
                        controller: _locationTextController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white),
                        decoration: _darkInputDecoration(
                          AppLocalizations.current.courseLocationHint,
                        ),
                      ),
                    )
                  else
                    CourseFieldCard(
                      label: AppLocalizations.current.onlineSessionLink,
                      child: TextField(
                        controller: _meetingLinkController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white),
                        decoration: _darkInputDecoration('https://...'),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CourseFieldCard(
                          label: AppLocalizations.current.priceIqdLabel,
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white),
                            decoration: _darkInputDecoration('50000'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CourseFieldCard(
                          label: AppLocalizations.current.seatsCountLabel,
                          child: TextField(
                            controller: _capacityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white),
                            decoration: _darkInputDecoration('5'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CourseFieldCard(
                    label: AppLocalizations.current.specialties,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_specialties.isNotEmpty)
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final specialty in _specialties)
                                LaqtaFilterPill(
                                  label: specialty,
                                  selected: true,
                                  onTap: () => setState(
                                    () => _specialties.remove(specialty),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _specialtyController,
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.white),
                                decoration: _darkInputDecoration(
                                  AppLocalizations.current.addSpecialtyHint,
                                ),
                                onSubmitted: (_) => _addSpecialty(),
                              ),
                            ),
                            IconButton(
                              onPressed: _addSpecialty,
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: LaqtaColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      TextButton.icon(
                        onPressed: _addSession,
                        icon: const Icon(
                          Icons.add,
                          color: LaqtaColors.accent,
                        ),
                        label: Text(
                          AppLocalizations.current.addSession,
                          style: const TextStyle(color: LaqtaColors.accent),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        AppLocalizations.current.sessionsLabel,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  if (_sessions.isNotEmpty)
                    LaqtaLuxurySurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _sessions.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                color: Color(0xFF2A2D33),
                                height: 16,
                              ),
                            Row(
                              textDirection: TextDirection.ltr,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFE24A3B),
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _sessions.removeAt(i)),
                                ),
                                Text(
                                  '${_formatMinutes(_sessions[i].startMinutes)} - '
                                  '${_formatMinutes(_sessions[i].endMinutes)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  _sessions[i].date,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFE24A3B)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      LaqtaPrimaryAction(
                        label: _isSaving ? AppLocalizations.current.savingProgress : AppLocalizations.current.save,
                        onTap: _isSaving ? null : _save,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}
