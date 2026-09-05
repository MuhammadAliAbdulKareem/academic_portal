import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/course_entity.dart';

/// Data Transfer Object for CourseEntity with Firestore map serialization.
class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.code,
    required super.title,
    required super.description,
    required super.instructorId,
    required super.instructorName,
    required super.term,
    required super.department,
    required super.credits,
    required super.schedule,
    required super.room,
    super.enrolledCount = 0,
    super.maxCapacity = 50,
    super.syllabus = const [],
    required super.createdAt,
  });

  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      code: entity.code,
      title: entity.title,
      description: entity.description,
      instructorId: entity.instructorId,
      instructorName: entity.instructorName,
      term: entity.term,
      department: entity.department,
      credits: entity.credits,
      schedule: entity.schedule,
      room: entity.room,
      enrolledCount: entity.enrolledCount,
      maxCapacity: entity.maxCapacity,
      syllabus: entity.syllabus,
      createdAt: entity.createdAt,
    );
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedCreatedAt;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      parsedCreatedAt = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    final rawSyllabus = map['syllabus'] as List<dynamic>? ?? [];
    final syllabusItems = rawSyllabus.map((item) {
      if (item is Map<String, dynamic>) {
        return SyllabusItem.fromMap(item);
      }
      return SyllabusItem.fromMap(Map<String, dynamic>.from(item as Map));
    }).toList();

    return CourseModel(
      id: id,
      code: map['code'] as String? ?? 'CRS-100',
      title: map['title'] as String? ?? 'Untitled Course',
      description: map['description'] as String? ?? '',
      instructorId: map['instructorId'] as String? ?? '',
      instructorName: map['instructorName'] as String? ?? 'Instructor',
      term: map['term'] as String? ?? 'Fall 2026',
      department: map['department'] as String? ?? 'Computer Science',
      credits: map['credits'] as int? ?? 3,
      schedule: map['schedule'] as String? ?? 'TBA',
      room: map['room'] as String? ?? 'Online',
      enrolledCount: map['enrolledCount'] as int? ?? 0,
      maxCapacity: map['maxCapacity'] as int? ?? 50,
      syllabus: syllabusItems,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'term': term,
      'department': department,
      'credits': credits,
      'schedule': schedule,
      'room': room,
      'enrolledCount': enrolledCount,
      'maxCapacity': maxCapacity,
      'syllabus': syllabus.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
