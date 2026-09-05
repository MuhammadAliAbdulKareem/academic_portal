import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_config.dart';
import '../../domain/entities/course_entity.dart';
import '../models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses({
    String? instructorId,
    String? department,
    String? searchQuery,
  });

  Future<CourseModel> getCourseById(String id);

  Future<CourseModel> createCourse(CourseEntity course);

  Future<CourseModel> updateCourse(CourseEntity course);

  Future<void> deleteCourse(String id);
}

/// Firestore remote data source with in-memory mock store fallback.
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final FirebaseFirestore? _firestore;

  CourseRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  bool get _isFirebaseReady => FirebaseConfig.isInitialized && _firestore != null;

  // In-memory mock storage pre-populated with foundational courses
  final List<CourseModel> _mockCourses = [
    CourseModel(
      id: 'course-cs-301',
      code: 'CS-301',
      title: 'Data Structures & Algorithms',
      description:
          'Comprehensive study of fundamental data structures including trees, graphs, heaps, and algorithmic complexity analysis.',
      instructorId: 'demo-inst-01',
      instructorName: 'Dr. Sarah Jenkins',
      term: 'Fall 2026',
      department: 'Computer Science',
      credits: 4,
      schedule: 'Mon / Wed • 10:00 AM - 11:30 AM',
      room: 'Hall B-104',
      enrolledCount: 48,
      maxCapacity: 50,
      syllabus: const [
        SyllabusItem(
          weekNumber: 1,
          title: 'Algorithmic Complexity & Big-O Notation',
          description: 'Introduction to time and space asymptotic analysis.',
        ),
        SyllabusItem(
          weekNumber: 2,
          title: 'Linear Data Structures',
          description: 'Linked lists, doubly linked lists, stacks, and queues.',
        ),
        SyllabusItem(
          weekNumber: 3,
          title: 'Trees & Balanced Binary Search Trees',
          description: 'AVL trees, Red-Black trees, and tree traversal algorithms.',
        ),
        SyllabusItem(
          weekNumber: 4,
          title: 'Priority Queues & Binary Heaps',
          description: 'Heapify, Heapsort, and priority queue applications.',
        ),
        SyllabusItem(
          weekNumber: 5,
          title: 'Graph Representation & Traversals',
          description: 'Adjacency list/matrix, BFS, DFS, and topological sort.',
        ),
      ],
      createdAt: DateTime(2026, 8, 15),
    ),
    CourseModel(
      id: 'course-cs-420',
      code: 'CS-420',
      title: 'Artificial Intelligence & Neural Networks',
      description:
          'Modern paradigms of machine learning, backpropagation, convolutional networks, transformers, and ethical AI design.',
      instructorId: 'demo-inst-01',
      instructorName: 'Dr. Sarah Jenkins',
      term: 'Fall 2026',
      department: 'Computer Science',
      credits: 3,
      schedule: 'Tue / Thu • 02:00 PM - 03:30 PM',
      room: 'Turing Lab 3',
      enrolledCount: 36,
      maxCapacity: 40,
      syllabus: const [
        SyllabusItem(
          weekNumber: 1,
          title: 'Introduction to Intelligent Agents',
          description: 'Search algorithms, A* heuristic search, and game playing.',
        ),
        SyllabusItem(
          weekNumber: 2,
          title: 'Supervised Learning & Perceptrons',
          description: 'Linear models, gradient descent, and activation functions.',
        ),
        SyllabusItem(
          weekNumber: 3,
          title: 'Deep Neural Networks & Backpropagation',
          description: 'Multi-layer perceptrons and auto-differentiation.',
        ),
      ],
      createdAt: DateTime(2026, 8, 18),
    ),
    CourseModel(
      id: 'course-se-210',
      code: 'SE-210',
      title: 'Object-Oriented Software Engineering',
      description:
          'Software architecture, design patterns, clean code principles, test-driven development, and collaborative Git workflows.',
      instructorId: 'demo-inst-01',
      instructorName: 'Dr. Sarah Jenkins',
      term: 'Fall 2026',
      department: 'Software Engineering',
      credits: 3,
      schedule: 'Friday • 09:00 AM - 12:00 PM',
      room: 'Auditorium 2',
      enrolledCount: 52,
      maxCapacity: 60,
      syllabus: const [
        SyllabusItem(
          weekNumber: 1,
          title: 'Object-Oriented Principles & SOLID',
          description: 'Encapsulation, abstraction, inheritance, and polymorphism.',
        ),
        SyllabusItem(
          weekNumber: 2,
          title: 'Creational & Structural Design Patterns',
          description: 'Factory, Singleton, Adapter, and Decorator patterns.',
        ),
        SyllabusItem(
          weekNumber: 3,
          title: 'Test-Driven Development & Clean Architecture',
          description: 'Unit testing, mocking, and repository patterns.',
        ),
      ],
      createdAt: DateTime(2026, 8, 20),
    ),
    CourseModel(
      id: 'course-math-201',
      code: 'MATH-201',
      title: 'Linear Algebra & Numerical Methods',
      description:
          'Matrix operations, eigenvalues, eigenvectors, vector spaces, and numerical approximations for computational engineering.',
      instructorId: 'prof-math-02',
      instructorName: 'Prof. Alan Turing',
      term: 'Fall 2026',
      department: 'Mathematics',
      credits: 4,
      schedule: 'Mon / Wed • 08:30 AM - 10:00 AM',
      room: 'Euler Hall 101',
      enrolledCount: 42,
      maxCapacity: 50,
      syllabus: const [
        SyllabusItem(
          weekNumber: 1,
          title: 'Systems of Linear Equations',
          description: 'Gaussian elimination, row echelon forms, and rank.',
        ),
        SyllabusItem(
          weekNumber: 2,
          title: 'Vector Spaces & Subspaces',
          description: 'Basis, dimension, and linear transformations.',
        ),
      ],
      createdAt: DateTime(2026, 8, 22),
    ),
  ];

  @override
  Future<List<CourseModel>> getCourses({
    String? instructorId,
    String? department,
    String? searchQuery,
  }) async {
    if (_isFirebaseReady) {
      try {
        Query<Map<String, dynamic>> query = _firestore!.collection('courses');
        if (instructorId != null && instructorId.isNotEmpty) {
          query = query.where('instructorId', isEqualTo: instructorId);
        }
        if (department != null && department.isNotEmpty && department != 'All') {
          query = query.where('department', isEqualTo: department);
        }

        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          var list = snapshot.docs
              .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
              .toList();

          if (searchQuery != null && searchQuery.trim().isNotEmpty) {
            final q = searchQuery.toLowerCase().trim();
            list = list.where((c) {
              return c.title.toLowerCase().contains(q) ||
                  c.code.toLowerCase().contains(q) ||
                  c.department.toLowerCase().contains(q);
            }).toList();
          }
          return list;
        }
      } catch (_) {
        // Fallback to in-memory on error
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<CourseModel>.from(_mockCourses);

    if (instructorId != null && instructorId.isNotEmpty) {
      results = results.where((c) => c.instructorId == instructorId).toList();
    }
    if (department != null && department.isNotEmpty && department != 'All') {
      results = results.where((c) => c.department == department).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      results = results.where((c) {
        return c.title.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q) ||
            c.department.toLowerCase().contains(q);
      }).toList();
    }

    return results;
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    if (_isFirebaseReady) {
      try {
        final doc = await _firestore!.collection('courses').doc(id).get();
        if (doc.exists && doc.data() != null) {
          return CourseModel.fromMap(doc.data()!, doc.id);
        }
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final found = _mockCourses.where((c) => c.id == id).firstOrNull;
    if (found != null) {
      return found;
    }
    throw Exception('Course with ID $id not found.');
  }

  @override
  Future<CourseModel> createCourse(CourseEntity course) async {
    final model = CourseModel.fromEntity(course);

    if (_isFirebaseReady) {
      try {
        final docRef = await _firestore!.collection('courses').add(model.toMap());
        return CourseModel.fromMap(model.toMap(), docRef.id);
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final generatedId = 'course-${DateTime.now().millisecondsSinceEpoch}';
    final savedCourse = CourseModel(
      id: generatedId,
      code: course.code,
      title: course.title,
      description: course.description,
      instructorId: course.instructorId,
      instructorName: course.instructorName,
      term: course.term,
      department: course.department,
      credits: course.credits,
      schedule: course.schedule,
      room: course.room,
      enrolledCount: course.enrolledCount,
      maxCapacity: course.maxCapacity,
      syllabus: course.syllabus,
      createdAt: course.createdAt,
    );

    _mockCourses.insert(0, savedCourse);
    return savedCourse;
  }

  @override
  Future<CourseModel> updateCourse(CourseEntity course) async {
    final model = CourseModel.fromEntity(course);

    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('courses').doc(course.id).set(model.toMap());
        return model;
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockCourses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _mockCourses[index] = model;
      return model;
    }
    _mockCourses.insert(0, model);
    return model;
  }

  @override
  Future<void> deleteCourse(String id) async {
    if (_isFirebaseReady) {
      try {
        await _firestore!.collection('courses').doc(id).delete();
      } catch (_) {}
    }

    await Future.delayed(const Duration(milliseconds: 100));
    _mockCourses.removeWhere((c) => c.id == id);
  }
}
