import 'package:laqta/features/courses/data/dtos/course_dto.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';

class CourseMapper {
  static Course toDomain(CourseDto dto) {
    return Course(
      id: dto.id,
      photographerId: dto.photographerId,
      title: dto.title,
      description: dto.description,
      type: dto.type,
      specialties: dto.specialties,
      basePrice: dto.basePrice,
      currency: dto.currency,
      capacity: dto.capacity,
      seatsRemaining: dto.seatsRemaining,
      sessions: dto.sessions
          .map(
            (s) => CourseSession(
              date: s.date,
              startMinutes: s.startMinutes,
              endMinutes: s.endMinutes,
            ),
          )
          .toList(),
      location: dto.location == null
          ? null
          : CourseLocation(
              lat: dto.location!.lat,
              lng: dto.location!.lng,
              text: dto.location!.text,
            ),
      meetingLink: dto.meetingLink,
      thumbnailUrl: dto.thumbnailUrl,
      isPublished: dto.isPublished,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static CourseDto toDto(Course course) {
    return CourseDto(
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
      sessions: course.sessions
          .map(
            (s) => CourseSessionDto(
              date: s.date,
              startMinutes: s.startMinutes,
              endMinutes: s.endMinutes,
            ),
          )
          .toList(),
      location: course.location == null
          ? null
          : CourseLocationDto(
              lat: course.location!.lat,
              lng: course.location!.lng,
              text: course.location!.text,
            ),
      meetingLink: course.meetingLink,
      thumbnailUrl: course.thumbnailUrl,
      isPublished: course.isPublished,
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
    );
  }
}
