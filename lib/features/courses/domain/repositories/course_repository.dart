import '../entities/course_entity.dart';

/// Contract for managing academic courses, rosters, and syllabus structures.
abstract class CourseRepository {
  Future<List<CourseEntity>> getCourses({
    String? instructorId,
    String? department,
    String? searchQuery,
  });

  Future<CourseEntity> getCourseById(String id);

  Future<CourseEntity> createCourse(CourseEntity course);

  Future<CourseEntity> updateCourse(CourseEntity course);

  Future<void> deleteCourse(String id);
}
