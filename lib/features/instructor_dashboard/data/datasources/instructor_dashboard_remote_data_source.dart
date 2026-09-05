import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/dashboard_entities.dart';

abstract class InstructorDashboardRemoteDataSource {
  Future<InstructorDashboardStats> getStats(String instructorId);
  Future<List<CourseSummaryEntity>> getCourses(String instructorId);
  Future<List<RecentActivityEntity>> getRecentActivities(String instructorId);
  Future<List<UpcomingDeadlineEntity>> getUpcomingDeadlines(String instructorId);
}

/// Remote data source integrating with Firestore with complete offline mock support.
class InstructorDashboardRemoteDataSourceImpl
    implements InstructorDashboardRemoteDataSource {
  final FirebaseFirestore? _firestore;

  InstructorDashboardRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  bool get _isFirebaseReady => FirebaseConfig.isInitialized && _firestore != null;

  @override
  Future<InstructorDashboardStats> getStats(String instructorId) async {
    if (_isFirebaseReady) {
      try {
        final coursesSnap = await _firestore!
            .collection('courses')
            .where('instructorId', isEqualTo: instructorId)
            .get();

        int totalStudents = 0;
        for (final doc in coursesSnap.docs) {
          totalStudents += (doc.data()['enrolledCount'] as int? ?? 0);
        }

        return InstructorDashboardStats(
          activeCourses: coursesSnap.docs.length,
          totalStudents: totalStudents,
          pendingGrading: 18,
          attendanceRate: 94.5,
        );
      } catch (_) {
        // Fallback to mock on network exception
      }
    }

    await Future.delayed(const Duration(milliseconds: 250));
    return const InstructorDashboardStats(
      activeCourses: 3,
      totalStudents: 136,
      pendingGrading: 18,
      attendanceRate: 94.2,
    );
  }

  @override
  Future<List<CourseSummaryEntity>> getCourses(String instructorId) async {
    if (_isFirebaseReady) {
      try {
        final snapshot = await _firestore!
            .collection('courses')
            .where('instructorId', isEqualTo: instructorId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return CourseSummaryEntity(
              id: doc.id,
              code: data['code'] as String? ?? 'CRS-100',
              title: data['title'] as String? ?? 'Untitled Course',
              term: data['term'] as String? ?? 'Fall 2026',
              enrolledCount: data['enrolledCount'] as int? ?? 0,
              schedule: data['schedule'] as String? ?? 'TBA',
              room: data['room'] as String? ?? 'Online',
              department: data['department'] as String? ?? 'General',
            );
          }).toList();
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      CourseSummaryEntity(
        id: 'course-cs-301',
        code: 'CS-301',
        title: 'Data Structures & Algorithms',
        term: 'Fall 2026',
        enrolledCount: 48,
        schedule: 'Mon / Wed • 10:00 AM',
        room: 'Hall B-104',
        department: 'Computer Science',
      ),
      CourseSummaryEntity(
        id: 'course-cs-420',
        code: 'CS-420',
        title: 'Artificial Intelligence & Neural Networks',
        term: 'Fall 2026',
        enrolledCount: 36,
        schedule: 'Tue / Thu • 02:00 PM',
        room: 'Turing Lab 3',
        department: 'Computer Science',
      ),
      CourseSummaryEntity(
        id: 'course-se-210',
        code: 'SE-210',
        title: 'Object-Oriented Software Engineering',
        term: 'Fall 2026',
        enrolledCount: 52,
        schedule: 'Friday • 09:00 AM',
        room: 'Auditorium 2',
        department: 'Software Engineering',
      ),
    ];
  }

  @override
  Future<List<RecentActivityEntity>> getRecentActivities(String instructorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      RecentActivityEntity(
        id: 'act-1',
        studentName: 'Alex Rivers',
        courseCode: 'CS-301',
        activityDescription: 'Submitted Project Milestone 2: Binary Search Trees',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        type: 'submission',
      ),
      RecentActivityEntity(
        id: 'act-2',
        studentName: 'Maya Lin',
        courseCode: 'CS-420',
        activityDescription: 'Asked a question: Backpropagation Gradient Clipping',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'question',
      ),
      RecentActivityEntity(
        id: 'act-3',
        studentName: 'David Kim',
        courseCode: 'SE-210',
        activityDescription: 'Enrolled in section with verified academic code',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'enrollment',
      ),
      RecentActivityEntity(
        id: 'act-4',
        studentName: 'Elena Rostova',
        courseCode: 'CS-301',
        activityDescription: 'Submitted Lab 4: Dijkstra Algorithm Analysis',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        type: 'submission',
      ),
    ];
  }

  @override
  Future<List<UpcomingDeadlineEntity>> getUpcomingDeadlines(String instructorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      UpcomingDeadlineEntity(
        id: 'dl-1',
        title: 'Assignment 3: Graph Traversal & BFS',
        courseCode: 'CS-301',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        submittedCount: 38,
        totalExpected: 48,
      ),
      UpcomingDeadlineEntity(
        id: 'dl-2',
        title: 'Quiz 2: Feedforward Architectures',
        courseCode: 'CS-420',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        submittedCount: 22,
        totalExpected: 36,
      ),
      UpcomingDeadlineEntity(
        id: 'dl-3',
        title: 'Software Architecture Proposal Document',
        courseCode: 'SE-210',
        dueDate: DateTime.now().add(const Duration(days: 6)),
        submittedCount: 45,
        totalExpected: 52,
      ),
    ];
  }
}
