import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/courses/course_dependencies.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';
import 'package:laqta/features/courses/domain/entities/course_enrollment.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<CourseEnrollment> _enrollments = const [];
  final Map<String, Course> _coursesById = {};

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

    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final result = await CourseDependencies.getMyEnrollments().call(userId);
    if (!mounted) return;
    if (!result.isSuccess) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final enrollments = result.valueOrNull ?? const [];
    final courseIds = enrollments.map((e) => e.courseId).toSet();
    for (final courseId in courseIds) {
      final courseResult = await CourseDependencies.getCourseById().call(
        courseId,
      );
      final course = courseResult.valueOrNull;
      if (course != null) {
        _coursesById[courseId] = course;
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _enrollments = enrollments;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    AppLocalizations.current.myCoursesTitle,
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
              ..._buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_isLoading) {
      return List.generate(
        3,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: LaqtaSkeletonBox(
            height: 80,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
      );
    }
    if (_hasError) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              AppLocalizations.current.myCoursesLoadError,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ];
    }
    if (_enrollments.isEmpty) {
      return [
        const SizedBox(height: 60),
        const Icon(Icons.menu_book_outlined, color: Colors.white38, size: 48),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.current.notEnrolledYet,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            AppLocalizations.current.browseCoursesPrompt,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          textDirection: TextDirection.ltr,
          children: [
            LaqtaPrimaryAction(
              label: AppLocalizations.current.browseCourses,
              onTap: () => AppRouter.goToCourses(context),
            ),
          ],
        ),
      ];
    }
    return _enrollments.map((enrollment) {
      final course = _coursesById[enrollment.courseId];
      final statusLabel = switch (enrollment.status) {
        'confirmed' => AppLocalizations.current.enrollmentConfirmed,
        'canceled' => AppLocalizations.current.enrollmentCanceled,
        _ => AppLocalizations.current.awaitingPayment,
      };
      final statusColor = switch (enrollment.status) {
        'confirmed' => LaqtaColors.success,
        'canceled' => const Color(0xFFE24A3B),
        _ => LaqtaColors.accent,
      };
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: course == null
              ? null
              : () => AppRouter.goToCourseDetails(context, course.id),
          child: LaqtaLuxurySurface(
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Icon(
                  enrollment.isConfirmed
                      ? Icons.check_circle
                      : Icons.hourglass_top_outlined,
                  color: statusColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        course?.title ?? enrollment.courseId,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
