import 'package:equatable/equatable.dart';

/// Represents a single topic/unit in a course's syllabus timeline.
class SyllabusItem extends Equatable {
  final int weekNumber;
  final String title;
  final String description;
  final String? readings;

  const SyllabusItem({
    required this.weekNumber,
    required this.title,
    required this.description,
    this.readings,
  });

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'title': title,
      'description': description,
      'readings': readings,
    };
  }

  factory SyllabusItem.fromMap(Map<String, dynamic> map) {
    return SyllabusItem(
      weekNumber: map['weekNumber'] as int? ?? 1,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      readings: map['readings'] as String?,
    );
  }

  @override
  List<Object?> get props => [weekNumber, title, description, readings];
}

/// Core domain entity representing an academic course offering.
class CourseEntity extends Equatable {
  final String id;
  final String code;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String term;
  final String department;
  final int credits;
  final String schedule;
  final String room;
  final int enrolledCount;
  final int maxCapacity;
  final List<SyllabusItem> syllabus;
  final DateTime createdAt;

  const CourseEntity({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.term,
    required this.department,
    required this.credits,
    required this.schedule,
    required this.room,
    this.enrolledCount = 0,
    this.maxCapacity = 50,
    this.syllabus = const [],
    required this.createdAt,
  });

  bool get isFull => enrolledCount >= maxCapacity;
  double get enrollmentRatio =>
      maxCapacity > 0 ? (enrolledCount / maxCapacity).clamp(0.0, 1.0) : 0.0;

  CourseEntity copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? instructorId,
    String? instructorName,
    String? term,
    String? department,
    int? credits,
    String? schedule,
    String? room,
    int? enrolledCount,
    int? maxCapacity,
    List<SyllabusItem>? syllabus,
    DateTime? createdAt,
  }) {
    return CourseEntity(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      term: term ?? this.term,
      department: department ?? this.department,
      credits: credits ?? this.credits,
      schedule: schedule ?? this.schedule,
      room: room ?? this.room,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      syllabus: syllabus ?? this.syllabus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        description,
        instructorId,
        instructorName,
        term,
        department,
        credits,
        schedule,
        room,
        enrolledCount,
        maxCapacity,
        syllabus,
        createdAt,
      ];
}
