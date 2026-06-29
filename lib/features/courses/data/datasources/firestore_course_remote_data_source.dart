import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:flutter/foundation.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:laqta/features/courses/data/dtos/course_dto.dart';

class FirestoreCourseRemoteDataSource implements CourseRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;

  FirestoreCourseRemoteDataSource({LegacyDataStore? firestore})
    : _firestore = firestore ?? LegacyDataStore.instance,
      _secure = SecureFirestore(firestore ?? LegacyDataStore.instance);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('courses');

  @override
  Future<List<CourseDto>> listPublishedCourses({String? specialty}) async {
    Query<Map<String, dynamic>> query = _collection.where(
      'isPublished',
      isEqualTo: true,
    );
    if (specialty != null && specialty.isNotEmpty) {
      query = query.where('specialties', arrayContains: specialty);
    }
    if (!kDebugMode) {
      query = query.orderBy('createdAt', descending: true);
    }
    final snapshot = await _secure.guard(
      () => query.limit(AppConstants.queryLimit).get(),
    );
    return snapshot.docs.map(CourseDto.fromFirestore).toList();
  }

  @override
  Future<List<CourseDto>> getCoursesByPhotographer(
    String photographerId,
  ) async {
    Query<Map<String, dynamic>> query = _collection.where(
      'photographerId',
      isEqualTo: photographerId,
    );
    if (!kDebugMode) {
      query = query.orderBy('createdAt', descending: true);
    }
    final snapshot = await _secure.guard(
      () => query.limit(AppConstants.queryLimit).get(),
    );
    return snapshot.docs.map(CourseDto.fromFirestore).toList();
  }

  @override
  Future<CourseDto> getCourseById(String courseId) async {
    final doc = await _secure.guard(() => _collection.doc(courseId).get());
    if (!doc.exists) {
      throw StateError('Course not found');
    }
    return CourseDto.fromFirestore(doc);
  }

  @override
  Future<String> createCourse(CourseDto course) async {
    final docRef = _collection.doc();
    await _secure.guard(() => docRef.set(course.toMap()));
    return docRef.id;
  }

  @override
  Future<void> updateCourse(String courseId, CourseDto course) async {
    await _secure.guard(() => _collection.doc(courseId).update(course.toMap()));
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _secure.guard(() => _collection.doc(courseId).delete());
  }
}
