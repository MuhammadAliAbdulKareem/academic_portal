import 'package:equatable/equatable.dart';

/// Status of an individual student's attendance record.
enum AttendanceStatus {
  present,
  late,
  absent,
  excused;

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  static AttendanceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      case 'absent':
      default:
        return AttendanceStatus.absent;
    }
  }
}

/// Verification method used for check-in.
enum CheckInMethod {
  qrCode,
  pinCode,
  manualOverride;

  String get displayName {
    switch (this) {
      case CheckInMethod.qrCode:
        return 'QR Code Scan';
      case CheckInMethod.pinCode:
        return '6-Digit PIN';
      case CheckInMethod.manualOverride:
        return 'Faculty Override';
    }
  }

  static CheckInMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'qrcode':
      case 'qr':
        return CheckInMethod.qrCode;
      case 'pincode':
      case 'pin':
        return CheckInMethod.pinCode;
      case 'manualoverride':
      case 'manual':
      default:
        return CheckInMethod.manualOverride;
    }
  }
}

/// Represents a live or archived attendance session for a class lecture/lab.
class AttendanceSessionEntity extends Equatable {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String section;
  final String title;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final String qrToken;
  final String sessionPin;
  final bool isActive;
  final DateTime expiresAt;
  final int totalEnrolled;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int excusedCount;

  const AttendanceSessionEntity({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.section,
    required this.title,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.qrToken,
    required this.sessionPin,
    required this.isActive,
    required this.expiresAt,
    required this.totalEnrolled,
    this.presentCount = 0,
    this.lateCount = 0,
    this.absentCount = 0,
    this.excusedCount = 0,
  });

  /// Count of attended students (present + late).
  int get attendedCount => presentCount + lateCount;

  /// Overall session attendance percentage.
  double get attendanceRate =>
      totalEnrolled == 0 ? 0.0 : (attendedCount / totalEnrolled) * 100.0;

  /// Check if the session is currently past its expiry window.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AttendanceSessionEntity copyWith({
    String? id,
    String? courseId,
    String? courseCode,
    String? courseTitle,
    String? section,
    String? title,
    String? room,
    DateTime? startTime,
    DateTime? endTime,
    String? qrToken,
    String? sessionPin,
    bool? isActive,
    DateTime? expiresAt,
    int? totalEnrolled,
    int? presentCount,
    int? lateCount,
    int? absentCount,
    int? excusedCount,
  }) {
    return AttendanceSessionEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      section: section ?? this.section,
      title: title ?? this.title,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      qrToken: qrToken ?? this.qrToken,
      sessionPin: sessionPin ?? this.sessionPin,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      totalEnrolled: totalEnrolled ?? this.totalEnrolled,
      presentCount: presentCount ?? this.presentCount,
      lateCount: lateCount ?? this.lateCount,
      absentCount: absentCount ?? this.absentCount,
      excusedCount: excusedCount ?? this.excusedCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseCode,
        courseTitle,
        section,
        title,
        room,
        startTime,
        endTime,
        qrToken,
        sessionPin,
        isActive,
        expiresAt,
        totalEnrolled,
        presentCount,
        lateCount,
        absentCount,
        excusedCount,
      ];
}

/// Represents an individual student's attendance record for a specific session.
class AttendanceRecordEntity extends Equatable {
  final String id;
  final String sessionId;
  final String courseId;
  final String courseCode;
  final String sessionTitle;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentAvatar;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final CheckInMethod? checkInMethod;
  final String? notes;

  const AttendanceRecordEntity({
    required this.id,
    required this.sessionId,
    required this.courseId,
    required this.courseCode,
    required this.sessionTitle,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentAvatar,
    required this.status,
    this.checkInTime,
    this.checkInMethod,
    this.notes,
  });

  AttendanceRecordEntity copyWith({
    String? id,
    String? sessionId,
    String? courseId,
    String? courseCode,
    String? sessionTitle,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? studentAvatar,
    AttendanceStatus? status,
    DateTime? checkInTime,
    CheckInMethod? checkInMethod,
    String? notes,
  }) {
    return AttendanceRecordEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentAvatar: studentAvatar ?? this.studentAvatar,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkInMethod: checkInMethod ?? this.checkInMethod,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        courseId,
        courseCode,
        sessionTitle,
        studentId,
        studentName,
        studentEmail,
        studentAvatar,
        status,
        checkInTime,
        checkInMethod,
        notes,
      ];
}

/// Aggregated attendance summary for a student in a course.
class StudentAttendanceSummaryEntity extends Equatable {
  final String studentId;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final int totalSessions;
  final int presentSessions;
  final int lateSessions;
  final int absentSessions;
  final int excusedSessions;

  const StudentAttendanceSummaryEntity({
    required this.studentId,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.totalSessions,
    required this.presentSessions,
    required this.lateSessions,
    required this.absentSessions,
    required this.excusedSessions,
  });

  int get attendedSessions => presentSessions + lateSessions;

  double get attendanceRate => totalSessions == 0
      ? 100.0
      : (attendedSessions / totalSessions) * 100.0;

  bool get isAtRisk => attendanceRate < 75.0 && totalSessions >= 3;

  @override
  List<Object?> get props => [
        studentId,
        courseId,
        courseCode,
        courseTitle,
        totalSessions,
        presentSessions,
        lateSessions,
        absentSessions,
        excusedSessions,
      ];
}
