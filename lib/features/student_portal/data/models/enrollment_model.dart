import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/enrollment_entity.dart';

/// Data Transfer Object for EnrollmentEntity with Firestore map serialization.
class EnrollmentModel extends EnrollmentEntity {
  const EnrollmentModel({
    required super.id,
    required super.studentId,
    required super.courseId,
    required super.courseCode,
    required super.courseTitle,
    required super.instructorName,
    required super.department,
    required super.term,
    required super.credits,
    required super.schedule,
    required super.room,
    super.status = EnrollmentStatus.active,
    required super.enrolledAt,
    super.grade,
    super.completedModules = 0,
    super.totalModules = 10,
  });

  factory EnrollmentModel.fromEntity(EnrollmentEntity entity) {
    return EnrollmentModel(
      id: entity.id,
      studentId: entity.studentId,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      courseTitle: entity.courseTitle,
      instructorName: entity.instructorName,
      department: entity.department,
      term: entity.term,
      credits: entity.credits,
      schedule: entity.schedule,
      room: entity.room,
      status: entity.status,
      enrolledAt: entity.enrolledAt,
      grade: entity.grade,
      completedModules: entity.completedModules,
      totalModules: entity.totalModules,
    );
  }

  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedEnrolledAt;
    final rawEnrolledAt = map['enrolledAt'];
    if (rawEnrolledAt is Timestamp) {
      parsedEnrolledAt = rawEnrolledAt.toDate();
    } else if (rawEnrolledAt is String) {
      parsedEnrolledAt = DateTime.tryParse(rawEnrolledAt) ?? DateTime.now();
    } else {
      parsedEnrolledAt = DateTime.now();
    }

    final rawStatus = map['status'] as String? ?? 'active';
    final status = switch (rawStatus.toLowerCase()) {
      'dropped' => EnrollmentStatus.dropped,
      'completed' => EnrollmentStatus.completed,
      _ => EnrollmentStatus.active,
    };

    return EnrollmentModel(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      courseCode: map['courseCode'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? '',
      instructorName: map['instructorName'] as String? ?? '',
      department: map['department'] as String? ?? 'General',
      term: map['term'] as String? ?? 'Fall 2026',
      credits: map['credits'] as int? ?? 3,
      schedule: map['schedule'] as String? ?? '',
      room: map['room'] as String? ?? '',
      status: status,
      enrolledAt: parsedEnrolledAt,
      grade: map['grade'] as String?,
      completedModules: map['completedModules'] as int? ?? 0,
      totalModules: map['totalModules'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'instructorName': instructorName,
      'department': department,
      'term': term,
      'credits': credits,
      'schedule': schedule,
      'room': room,
      'status': status.name,
      'enrolledAt': enrolledAt.toIso8601String(),
      'grade': grade,
      'completedModules': completedModules,
      'totalModules': totalModules,
    };
  }
}
