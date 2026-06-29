import 'package:flutter/material.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/core/widgets/laqta_marketplace_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/courses/course_dependencies.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() =>
      _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Course> _courses = const [];

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

    final result = await CourseDependencies.getCoursesByPhotographer().call(
      userId,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = !result.isSuccess;
      _courses = result.valueOrNull ?? const [];
    });
  }

  Future<void> _deleteCourse(Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17191F),
        title: const Text('حذف الدورة', style: TextStyle(color: Colors.white)),
        content: Text(
          'هل تريد حذف "${course.title}"؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'حذف',
              style: TextStyle(color: Color(0xFFE24A3B)),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await CourseDependencies.deleteCourse().call(course.id);
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        _courses = _courses.where((c) => c.id != course.id).toList();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل حذف الدورة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaqtaColors.canvasDark,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: LaqtaColors.accent,
        foregroundColor: Colors.black,
        onPressed: () async {
          final created = await AppRouter.goToCourseCreate(context);
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'دورة جديدة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
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
                    'دوراتي التعليمية',
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
              const SizedBox(height: 80),
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
            height: 100,
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
      );
    }
    if (_hasError) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              'حدث خطأ في تحميل الدورات',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ];
    }
    if (_courses.isEmpty) {
      return const [
        SizedBox(height: 60),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Icon(Icons.school_outlined, color: Colors.white38, size: 48),
                SizedBox(height: 12),
                Text(
                  'لا توجد دورات بعد',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'أنشئ أول دورة تصوير تعليمية لك للبدء باستقبال المتدربين.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    return _courses
        .map(
          (course) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LaqtaLuxurySurface(
              padding: const EdgeInsets.all(14),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFE24A3B),
                    ),
                    onPressed: () => _deleteCourse(course),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: LaqtaColors.accent,
                    ),
                    onPressed: () async {
                      final updated = await AppRouter.goToCourseEdit(
                        context,
                        course.id,
                      );
                      if (updated == true) _load();
                    },
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: course.thumbnailUrl == null ||
                            course.thumbnailUrl!.isEmpty
                        ? Container(
                            width: 56,
                            height: 56,
                            color: const Color(0xFF17191F),
                            alignment: Alignment.center,
                            child: Icon(
                              course.isInPerson
                                  ? Icons.school_outlined
                                  : Icons.videocam_outlined,
                              color: LaqtaColors.accent,
                              size: 22,
                            ),
                          )
                        : LaqtaRemoteImage(
                            imageUrl: course.thumbnailUrl,
                            width: 56,
                            height: 56,
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          course.title,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.isInPerson ? "حضوري" : "أونلاين"} • '
                          '${course.seatsRemaining}/${course.capacity} مقعد',
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: Color(0xFFB7B9BE)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: course.isPublished
                                ? LaqtaColors.success.withValues(alpha: 0.16)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            course.isPublished ? 'منشورة' : 'مسودة',
                            style: TextStyle(
                              color: course.isPublished
                                  ? LaqtaColors.success
                                  : Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }
}
