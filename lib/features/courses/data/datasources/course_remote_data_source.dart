import 'package:laqta/features/courses/data/dtos/course_dto.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseDto>> listPublishedCourses({String? specialty});

  Future<List<CourseDto>> getCoursesByPhotographer(String photographerId);

  Future<CourseDto> getCourseById(String courseId);

  Future<String> createCourse(CourseDto course);

  Future<void> updateCourse(String courseId, CourseDto course);

  Future<void> deleteCourse(String courseId);
}
