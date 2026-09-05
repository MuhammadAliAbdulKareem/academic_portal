import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_config.dart';
import 'package:academic_portal/features/courses/domain/entities/course_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../models/enrollment_model.dart';

abstract class EnrollmentRemoteDataSource {
  Future<List<EnrollmentModel>> getEnrollments(String studentId);
  Future<bool> isEnrolled({required String studentId, required String courseId});
  Future<EnrollmentModel> enrollCourse({
    required String studentId,
    required CourseEntity course,
  });
  Future<void> dropCourse({required String studentId, required String courseId});
  Future<StudentDashboardStats> getStats(String studentId);
  Future<List<StudentScheduleItem>> getSchedule(String studentId);
  Future<List<StudentDeadlineItem>> getDeadlines(String studentId);
  Future<void> submitAssignment({
    required String studentId,
    required String deadlineId,
  });
}

/// Remote data source integrating Cloud Firestore with in-memory mock fallback.
class EnrollmentRemoteDataSourceImpl implements EnrollmentRemoteDataSource {
  final FirebaseFirestore? _firestore;

  EnrollmentRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  bool get _isFirebaseReady => FirebaseConfig.isInitialized && _firestore != null;

  // In-memory mock enrollments store
  final List<EnrollmentModel> _mockEnrollments = [
    EnrollmentModel(
      id: 'enr-demo-01',
      studentId: 'demo-student-01',
      courseId: 'course-cs-301',
      courseCode: 'CS-301',
      courseTitle: 'Data Structures & Algorithms',
      instructorName: 'Dr. Sarah Jenkins',
      department: 'Computer Science',
      term: 'Fall 2026',
      credits: 4,
      schedule: 'Mon / Wed • 10:00 AM - 11:30 AM',
      room: 'Hall B-104',
      status: EnrollmentStatus.active,
      enrolledAt: DateTime(2026, 8, 20),
      grade: 'A-',
      completedModules: 3,
      totalModules: 5,
    ),
    EnrollmentModel(
      id: 'enr-demo-02',
      studentId: 'demo-student-01',
      courseId: 'course-cs-420',
      courseCode: 'CS-420',
      courseTitle: 'Artificial Intelligence & Neural Networks',
      instructorName: 'Dr. Sarah Jenkins',
      department: 'Computer Science',
      term: 'Fall 2026',
      credits: 3,
      schedule: 'Tue / Thu • 02:00 PM - 03:30 PM',
      room: 'Turing Lab 3',
      status: EnrollmentStatus.active,
      enrolledAt: DateTime(2026, 8, 22),
      grade: 'A',
      completedModules: 2,
      totalModules: 4,
    ),
  ];

  final List<StudentDeadlineItem> _mockDeadlines = [
    StudentDeadlineItem(
      id: 'task-01',
      courseCode: 'CS-301',
      title: 'Programming Assignment 2 — Balanced AVL Trees',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      points: 100,
      type: DeadlineType.assignment,
      status: DeadlineStatus.pending,
    ),
    StudentDeadlineItem(
      id: 'task-02',
      courseCode: 'CS-420',
      title: 'Lab Quiz 1 — Perceptrons & Loss Optimization',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      points: 50,
      type: DeadlineType.quiz,
      status: DeadlineStatus.pending,
    ),
    StudentDeadlineItem(
      id: 'task-03',
      courseCode: 'CS-301',
      title: 'Written Homework 1 — Asymptotic Analysis',
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      points: 100,
      type: DeadlineType.assignment,
      status: DeadlineStatus.graded,
      earnedGrade: '95/100',
    ),
  ];

  @override
  Future<List<EnrollmentModel>> getEnrollments(String studentId) async {
    if (_isFirebaseReady) {
      try {
        final query = await _firestore!
            .collection('enrollments')
            .where('studentId', isEqualTo: studentId)
            .get();

        if (query.docs.isNotEmpty) {
          return query.docs
              .map((doc) => EnrollmentModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (_) {
        // Fallback to mock on remote query failure
      }
    }

    return _mockEnrollments
        .where((e) => (e.studentId == studentId || e.studentId == 'demo-student-01') && e.isActive)
        .toList();
  }

  @override
  Future<bool> isEnrolled({
    required String studentId,
    required String courseId,
  }) async {
    final list = await getEnrollments(studentId);
    return list.any((e) => e.courseId == courseId && e.isActive);
  }

  @override
  Future<EnrollmentModel> enrollCourse({
    required String studentId,
    required CourseEntity course,
  }) async {
    final enrollment = EnrollmentModel(
      id: 'enr-${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      courseId: course.id,
      courseCode: course.code,
      courseTitle: course.title,
      instructorName: course.instructorName,
      department: course.department,
      term: course.term,
      credits: course.credits,
      schedule: course.schedule,
      room: course.room,
      status: EnrollmentStatus.active,
      enrolledAt: DateTime.now(),
      completedModules: 0,
      totalModules: course.syllabus.isNotEmpty ? course.syllabus.length : 8,
    );

    if (_isFirebaseReady) {
      try {
        await _firestore!
            .collection('enrollments')
            .doc(enrollment.id)
            .set(enrollment.toMap());
      } catch (_) {
        // Continue with local cache fallback
      }
    }

    // Update in-memory storage (remove old dropped records for this course if any)
    _mockEnrollments.removeWhere(
      (e) => e.studentId == studentId && e.courseId == course.id,
    );
    _mockEnrollments.add(enrollment);

    return enrollment;
  }

  @override
  Future<void> dropCourse({
    required String studentId,
    required String courseId,
  }) async {
    if (_isFirebaseReady) {
      try {
        final query = await _firestore!
            .collection('enrollments')
            .where('studentId', isEqualTo: studentId)
            .where('courseId', isEqualTo: courseId)
            .get();

        for (final doc in query.docs) {
          await doc.reference.update({'status': EnrollmentStatus.dropped.name});
        }
      } catch (_) {
        // Fallback
      }
    }

    _mockEnrollments.removeWhere(
      (e) => (e.studentId == studentId || e.studentId == 'demo-student-01') && e.courseId == courseId,
    );
  }

  @override
  Future<StudentDashboardStats> getStats(String studentId) async {
    final enrollments = await getEnrollments(studentId);
    final activeCount = enrollments.length;
    final enrolledCredits = enrollments.fold<int>(0, (total, e) => total + e.credits);
    final pendingCount = _mockDeadlines.where((d) => d.isPending).length;

    return StudentDashboardStats(
      gpa: 3.84,
      enrolledCredits: enrolledCredits,
      maxCredits: 18,
      activeCoursesCount: activeCount,
      attendanceRate: 96.2,
      pendingAssignmentsCount: pendingCount,
      academicStanding: 'Good Standing (Dean\'s List)',
    );
  }

  @override
  Future<List<StudentScheduleItem>> getSchedule(String studentId) async {
    final enrollments = await getEnrollments(studentId);
    final items = <StudentScheduleItem>[];

    for (var i = 0; i < enrollments.length; i++) {
      final e = enrollments[i];
      items.add(
        StudentScheduleItem(
          courseCode: e.courseCode,
          courseTitle: e.courseTitle,
          instructorName: e.instructorName,
          time: e.schedule,
          room: e.room,
          dayOfWeek: 'Mon / Wed',
          isLiveNow: i == 0,
        ),
      );
    }

    return items;
  }

  @override
  Future<List<StudentDeadlineItem>> getDeadlines(String studentId) async {
    return List.unmodifiable(_mockDeadlines);
  }

  @override
  Future<void> submitAssignment({
    required String studentId,
    required String deadlineId,
  }) async {
    final index = _mockDeadlines.indexWhere((d) => d.id == deadlineId);
    if (index != -1) {
      final item = _mockDeadlines[index];
      _mockDeadlines[index] = StudentDeadlineItem(
        id: item.id,
        courseCode: item.courseCode,
        title: item.title,
        dueDate: item.dueDate,
        points: item.points,
        type: item.type,
        status: DeadlineStatus.submitted,
      );
    }
  }
}
