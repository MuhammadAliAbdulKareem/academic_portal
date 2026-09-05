import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';

/// Data model representing an attendance session with serialization support.
class AttendanceSessionModel extends AttendanceSessionEntity {
  const AttendanceSessionModel({
    required super.id,
    required super.courseId,
    required super.courseCode,
    required super.courseTitle,
    required super.section,
    required super.title,
    required super.room,
    required super.startTime,
    required super.endTime,
    required super.qrToken,
    required super.sessionPin,
    required super.isActive,
    required super.expiresAt,
    required super.totalEnrolled,
    super.presentCount = 0,
    super.lateCount = 0,
    super.absentCount = 0,
    super.excusedCount = 0,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return AttendanceSessionModel(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      courseTitle: json['courseTitle'] as String? ?? '',
      section: json['section'] as String? ?? '',
      title: json['title'] as String? ?? '',
      room: json['room'] as String? ?? '',
      startTime: parseDateTime(json['startTime']),
      endTime: parseDateTime(json['endTime']),
      qrToken: json['qrToken'] as String? ?? '',
      sessionPin: json['sessionPin'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      expiresAt: parseDateTime(json['expiresAt']),
      totalEnrolled: (json['totalEnrolled'] as num?)?.toInt() ?? 0,
      presentCount: (json['presentCount'] as num?)?.toInt() ?? 0,
      lateCount: (json['lateCount'] as num?)?.toInt() ?? 0,
      absentCount: (json['absentCount'] as num?)?.toInt() ?? 0,
      excusedCount: (json['excusedCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'section': section,
      'title': title,
      'room': room,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'qrToken': qrToken,
      'sessionPin': sessionPin,
      'isActive': isActive,
      'expiresAt': expiresAt.toIso8601String(),
      'totalEnrolled': totalEnrolled,
      'presentCount': presentCount,
      'lateCount': lateCount,
      'absentCount': absentCount,
      'excusedCount': excusedCount,
    };
  }

  factory AttendanceSessionModel.fromEntity(AttendanceSessionEntity entity) {
    return AttendanceSessionModel(
      id: entity.id,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      courseTitle: entity.courseTitle,
      section: entity.section,
      title: entity.title,
      room: entity.room,
      startTime: entity.startTime,
      endTime: entity.endTime,
      qrToken: entity.qrToken,
      sessionPin: entity.sessionPin,
      isActive: entity.isActive,
      expiresAt: entity.expiresAt,
      totalEnrolled: entity.totalEnrolled,
      presentCount: entity.presentCount,
      lateCount: entity.lateCount,
      absentCount: entity.absentCount,
      excusedCount: entity.excusedCount,
    );
  }
}

/// Data model representing an individual student's attendance record with serialization support.
class AttendanceRecordModel extends AttendanceRecordEntity {
  const AttendanceRecordModel({
    required super.id,
    required super.sessionId,
    required super.courseId,
    required super.courseCode,
    required super.sessionTitle,
    required super.studentId,
    required super.studentName,
    required super.studentEmail,
    super.studentAvatar,
    required super.status,
    super.checkInTime,
    super.checkInMethod,
    super.notes,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    final statusStr = json['status'] as String? ?? 'absent';
    final methodStr = json['checkInMethod'] as String?;

    return AttendanceRecordModel(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      sessionTitle: json['sessionTitle'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      studentEmail: json['studentEmail'] as String? ?? '',
      studentAvatar: json['studentAvatar'] as String?,
      status: AttendanceStatus.fromString(statusStr),
      checkInTime: parseDateTime(json['checkInTime']),
      checkInMethod:
          methodStr != null ? CheckInMethod.fromString(methodStr) : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'courseId': courseId,
      'courseCode': courseCode,
      'sessionTitle': sessionTitle,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentAvatar': studentAvatar,
      'status': status.name,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkInMethod': checkInMethod?.name,
      'notes': notes,
    };
  }

  factory AttendanceRecordModel.fromEntity(AttendanceRecordEntity entity) {
    return AttendanceRecordModel(
      id: entity.id,
      sessionId: entity.sessionId,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      sessionTitle: entity.sessionTitle,
      studentId: entity.studentId,
      studentName: entity.studentName,
      studentEmail: entity.studentEmail,
      studentAvatar: entity.studentAvatar,
      status: entity.status,
      checkInTime: entity.checkInTime,
      checkInMethod: entity.checkInMethod,
      notes: entity.notes,
    );
  }
}

/// Data model representing student attendance metrics summary.
class StudentAttendanceSummaryModel extends StudentAttendanceSummaryEntity {
  const StudentAttendanceSummaryModel({
    required super.studentId,
    required super.courseId,
    required super.courseCode,
    required super.courseTitle,
    required super.totalSessions,
    required super.presentSessions,
    required super.lateSessions,
    required super.absentSessions,
    required super.excusedSessions,
  });

  factory StudentAttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummaryModel(
      studentId: json['studentId'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      courseTitle: json['courseTitle'] as String? ?? '',
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      presentSessions: (json['presentSessions'] as num?)?.toInt() ?? 0,
      lateSessions: (json['lateSessions'] as num?)?.toInt() ?? 0,
      absentSessions: (json['absentSessions'] as num?)?.toInt() ?? 0,
      excusedSessions: (json['excusedSessions'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'totalSessions': totalSessions,
      'presentSessions': presentSessions,
      'lateSessions': lateSessions,
      'absentSessions': absentSessions,
      'excusedSessions': excusedSessions,
    };
  }

  factory StudentAttendanceSummaryModel.fromEntity(
    StudentAttendanceSummaryEntity entity,
  ) {
    return StudentAttendanceSummaryModel(
      studentId: entity.studentId,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      courseTitle: entity.courseTitle,
      totalSessions: entity.totalSessions,
      presentSessions: entity.presentSessions,
      lateSessions: entity.lateSessions,
      absentSessions: entity.absentSessions,
      excusedSessions: entity.excusedSessions,
    );
  }
}
