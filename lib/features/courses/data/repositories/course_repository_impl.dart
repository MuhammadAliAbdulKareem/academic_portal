import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_data_source.dart';

/// Concrete repository bridging domain course operations with remote data source.
class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _remoteDataSource;

  CourseRepositoryImpl({
    required CourseRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<CourseEntity>> getCourses({
    String? instructorId,
    String? department,
    String? searchQuery,
  }) async {
    return await _remoteDataSource.getCourses(
      instructorId: instructorId,
      department: department,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<CourseEntity> getCourseById(String id) async {
    return await _remoteDataSource.getCourseById(id);
  }

  @override
  Future<CourseEntity> createCourse(CourseEntity course) async {
    return await _remoteDataSource.createCourse(course);
  }

  @override
  Future<CourseEntity> updateCourse(CourseEntity course) async {
    return await _remoteDataSource.updateCourse(course);
  }

  @override
  Future<void> deleteCourse(String id) async {
    return await _remoteDataSource.deleteCourse(id);
  }
}
