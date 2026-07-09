import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/courses/course_dependencies.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Course> _courses = const [];
  String _selectedSpecialty = 'الكل';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    final result = await CourseDependencies.listPublishedCourses().call();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = !result.isSuccess;
      _courses = result.valueOrNull ?? const [];
    });
  }

  List<String> get _specialties {
    final values =
        _courses.expand((c) => c.specialties).toSet().toList()..sort();
    return ['الكل', ...values];
  }

  List<Course> get _filteredCourses {
    if (_selectedSpecialty == 'الكل') return _courses;
    return _courses
        .where((c) => c.specialties.contains(_selectedSpecialty))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _filteredCourses;
    final specialties = _specialties;

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  const LaqtaHeaderBackButton(),
                  const Spacer(),
                  Text(
                    AppLocalizations.current.coursesListTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),
              const SizedBox(height: 16),
              if (specialties.length > 1) ...[
                SizedBox(
                  height: 42,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final chip = specialties[index];
                        return LaqtaFilterPill(
                          label: chip == 'الكل'
                              ? AppLocalizations.current.allFilter
                              : chip,
                          selected: chip == _selectedSpecialty,
                          onTap: () =>
                              setState(() => _selectedSpecialty = chip),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemCount: specialties.length,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_isLoading && _courses.isEmpty)
                ...List.generate(
                  4,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LaqtaSkeletonBox(
                      height: 110,
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                  ),
                )
              else if (visibleItems.isEmpty && _hasError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      AppLocalizations.current.coursesLoadError,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else if (visibleItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      AppLocalizations.current.noCoursesAvailable,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...visibleItems.map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () =>
                          AppRouter.goToCourseDetails(context, course.id),
                      child: LaqtaLuxurySurface(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: course.thumbnailUrl == null ||
                                      course.thumbnailUrl!.isEmpty
                                  ? Container(
                                      width: 96,
                                      height: 84,
                                      color: const Color(0xFF17191F),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        course.isInPerson
                                            ? Icons.school_outlined
                                            : Icons.videocam_outlined,
                                        color: LaqtaColors.accent,
                                        size: 32,
                                      ),
                                    )
                                  : LaqtaRemoteImage(
                                      imageUrl: course.thumbnailUrl,
                                      width: 96,
                                      height: 84,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    course.title,
                                    textAlign: TextAlign.right,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    course.isInPerson
                                        ? AppLocalizations.current.inPersonLabel
                                        : AppLocalizations.current.onlineLabel,
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFFB7B9BE),
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (course.isFull)
                                        Text(
                                          AppLocalizations.current.courseFull,
                                          style: const TextStyle(
                                            color: Color(0xFFE24A3B),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else
                                        Text(
                                          AppLocalizations.current.seatsCount(
                                            course.seatsRemaining,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      const Spacer(),
                                      Text(
                                        '${course.basePrice.toStringAsFixed(0)} ${course.currency}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: LaqtaColors.accent,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
