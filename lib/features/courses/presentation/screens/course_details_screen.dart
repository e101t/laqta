import 'package:flutter/material.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/courses/course_dependencies.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool _isLoading = true;
  bool _isEnrolling = false;
  String? _error;
  Course? _course;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await CourseDependencies.getCourseById().call(
      widget.courseId,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _course = result.valueOrNull;
      if (!result.isSuccess) _error = 'تعذر تحميل بيانات الدورة';
    });
  }

  String _formatMinutes(int minutes) {
    final h = (minutes ~/ 60).toString().padLeft(2, '0');
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _enroll() async {
    final course = _course;
    if (course == null || _isEnrolling) return;

    setState(() => _isEnrolling = true);

    final enrollResult = await CourseDependencies.enrollInCourse().call(
      course.id,
    );
    if (!mounted) return;

    if (!enrollResult.isSuccess || enrollResult.valueOrNull == null) {
      setState(() => _isEnrolling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إنشاء التسجيل، حاول مرة أخرى')),
      );
      return;
    }

    final enrollmentId = enrollResult.valueOrNull!;
    setState(() => _isEnrolling = false);

    if (!mounted) return;
    final paid = await AppRouter.goToCoursePayment(
      context,
      enrollmentId,
      course.basePrice,
      course.title,
      course.photographerId,
    );
    if (paid == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;

    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : course == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error ?? 'لم يتم العثور على الدورة',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Row(
                    textDirection: TextDirection.ltr,
                    children: [LaqtaHeaderBackButton()],
                  ),
                  const SizedBox(height: 16),
                  if (course.thumbnailUrl != null &&
                      course.thumbnailUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: LaqtaRemoteImage(
                        imageUrl: course.thumbnailUrl,
                        height: 180,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    course.title,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      LaqtaFeaturePill(
                        icon: course.isInPerson
                            ? Icons.location_on_outlined
                            : Icons.videocam_outlined,
                        label: course.isInPerson ? 'حضوري' : 'أونلاين',
                      ),
                      for (final specialty in course.specialties)
                        LaqtaFeaturePill(
                          icon: Icons.local_offer_outlined,
                          label: specialty,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LaqtaLuxurySurface(
                    child: Text(
                      course.description,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LaqtaLuxurySurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          textDirection: TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${course.seatsRemaining} من ${course.capacity}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Text(
                              'المقاعد المتاحة',
                              style: TextStyle(color: Color(0xFFB7B9BE)),
                            ),
                          ],
                        ),
                        if (course.isInPerson &&
                            course.location?.text != null &&
                            course.location!.text!.isNotEmpty) ...[
                          const Divider(color: Color(0xFF2A2D33), height: 20),
                          Row(
                            textDirection: TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                course.location!.text!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Text(
                                'الموقع',
                                style: TextStyle(color: Color(0xFFB7B9BE)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LaqtaSectionHeader(title: 'الجلسات'),
                  const SizedBox(height: 8),
                  LaqtaLuxurySurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < course.sessions.length; i++) ...[
                          if (i > 0)
                            const Divider(color: Color(0xFF2A2D33), height: 16),
                          Row(
                            textDirection: TextDirection.ltr,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_formatMinutes(course.sessions[i].startMinutes)} - '
                                '${_formatMinutes(course.sessions[i].endMinutes)}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                course.sessions[i].date,
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
                  const SizedBox(height: 24),
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(
                        child: Text(
                          '${course.basePrice.toStringAsFixed(0)} ${course.currency}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: LaqtaColors.accent,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      LaqtaPrimaryAction(
                        label: course.isFull
                            ? 'الدورة مكتملة'
                            : (_isEnrolling ? 'جارٍ التسجيل...' : 'سجّل الآن'),
                        onTap: (course.isFull || _isEnrolling)
                            ? null
                            : _enroll,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}
