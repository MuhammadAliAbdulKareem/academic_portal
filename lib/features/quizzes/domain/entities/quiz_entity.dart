import 'package:equatable/equatable.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  trueFalse,
  shortAnswer;

  String get displayName {
    switch (this) {
      case QuestionType.singleChoice:
        return 'Single Choice';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True / False';
      case QuestionType.shortAnswer:
        return 'Short Answer';
    }
  }
}

class QuizQuestionEntity extends Equatable {
  final String id;
  final String quizId;
  final String prompt;
  final QuestionType type;
  final List<String> options;
  final dynamic correctAnswer;
  final List<int> correctOptionIndices;
  final String explanation;
  final int points;

  const QuizQuestionEntity({
    required this.id,
    required this.quizId,
    required this.prompt,
    required this.type,
    this.options = const [],
    this.correctAnswer,
    this.correctOptionIndices = const [],
    this.explanation = '',
    this.points = 1,
  });

  bool isAnswerCorrect(dynamic studentAnswer) {
    if (studentAnswer == null) return false;

    switch (type) {
      case QuestionType.singleChoice:
        if (studentAnswer is int) {
          if (correctAnswer is int) return studentAnswer == correctAnswer;
          if (correctOptionIndices.isNotEmpty) {
            return correctOptionIndices.contains(studentAnswer);
          }
        }
        return false;

      case QuestionType.trueFalse:
        if (studentAnswer is bool) {
          if (correctAnswer is bool) return studentAnswer == correctAnswer;
        }
        if (studentAnswer is int && correctAnswer is int) {
          return studentAnswer == correctAnswer;
        }
        return false;

      case QuestionType.multipleChoice:
        if (studentAnswer is List) {
          final studentSet = studentAnswer.map((e) => e as int).toSet();
          final correctSet = correctOptionIndices.toSet();
          return studentSet.length == correctSet.length &&
              studentSet.containsAll(correctSet);
        }
        return false;

      case QuestionType.shortAnswer:
        if (studentAnswer is String && correctAnswer is String) {
          return studentAnswer.trim().toLowerCase() ==
              correctAnswer.trim().toLowerCase();
        }
        return false;
    }
  }

  QuizQuestionEntity copyWith({
    String? id,
    String? quizId,
    String? prompt,
    QuestionType? type,
    List<String>? options,
    dynamic correctAnswer,
    List<int>? correctOptionIndices,
    String? explanation,
    int? points,
  }) {
    return QuizQuestionEntity(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      prompt: prompt ?? this.prompt,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      correctOptionIndices:
          correctOptionIndices ?? this.correctOptionIndices,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
    );
  }

  @override
  List<Object?> get props => [
        id,
        quizId,
        prompt,
        type,
        options,
        correctAnswer,
        correctOptionIndices,
        explanation,
        points,
      ];
}

class QuizEntity extends Equatable {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseTitle;
  final String title;
  final String description;
  final int timeLimitMinutes;
  final int totalPoints;
  final double passingPercentage;
  final int maxAttempts;
  final bool isPublished;
  final bool shuffleQuestions;
  final bool allowReview;
  final DateTime availableFrom;
  final DateTime dueDate;
  final int questionsCount;

  const QuizEntity({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseTitle,
    required this.title,
    required this.description,
    required this.timeLimitMinutes,
    required this.totalPoints,
    this.passingPercentage = 70.0,
    this.maxAttempts = 1,
    this.isPublished = true,
    this.shuffleQuestions = false,
    this.allowReview = true,
    required this.availableFrom,
    required this.dueDate,
    required this.questionsCount,
  });

  bool get isExpired => DateTime.now().isAfter(dueDate);
  bool get isAvailable {
    final now = DateTime.now();
    return isPublished &&
        now.isAfter(availableFrom) &&
        now.isBefore(dueDate);
  }

  String get timeLimitFormatted {
    if (timeLimitMinutes <= 0) return 'Untimed';
    if (timeLimitMinutes < 60) return '$timeLimitMinutes Mins';
    final hours = timeLimitMinutes ~/ 60;
    final mins = timeLimitMinutes % 60;
    return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
  }

  QuizEntity copyWith({
    String? id,
    String? courseId,
    String? courseCode,
    String? courseTitle,
    String? title,
    String? description,
    int? timeLimitMinutes,
    int? totalPoints,
    double? passingPercentage,
    int? maxAttempts,
    bool? isPublished,
    bool? shuffleQuestions,
    bool? allowReview,
    DateTime? availableFrom,
    DateTime? dueDate,
    int? questionsCount,
  }) {
    return QuizEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseTitle: courseTitle ?? this.courseTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      totalPoints: totalPoints ?? this.totalPoints,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isPublished: isPublished ?? this.isPublished,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      allowReview: allowReview ?? this.allowReview,
      availableFrom: availableFrom ?? this.availableFrom,
      dueDate: dueDate ?? this.dueDate,
      questionsCount: questionsCount ?? this.questionsCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseCode,
        courseTitle,
        title,
        description,
        timeLimitMinutes,
        totalPoints,
        passingPercentage,
        maxAttempts,
        isPublished,
        shuffleQuestions,
        allowReview,
        availableFrom,
        dueDate,
        questionsCount,
      ];
}

class QuizAttemptEntity extends Equatable {
  final String id;
  final String quizId;
  final String studentId;
  final String studentName;
  final String? studentAvatar;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final Map<String, dynamic> answers;
  final int score;
  final int totalPossiblePoints;
  final double percentage;
  final bool passed;
  final bool isAutoGraded;
  final String? feedback;

  const QuizAttemptEntity({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.studentName,
    this.studentAvatar,
    required this.startedAt,
    this.submittedAt,
    this.answers = const {},
    required this.score,
    required this.totalPossiblePoints,
    required this.percentage,
    required this.passed,
    this.isAutoGraded = true,
    this.feedback,
  });

  bool get isCompleted => submittedAt != null;

  Duration get timeTaken {
    if (submittedAt == null) return Duration.zero;
    return submittedAt!.difference(startedAt);
  }

  String get timeTakenFormatted {
    final d = timeTaken;
    final mins = d.inMinutes;
    final secs = d.inSeconds % 60;
    return '${mins}m ${secs}s';
  }

  QuizAttemptEntity copyWith({
    String? id,
    String? quizId,
    String? studentId,
    String? studentName,
    String? studentAvatar,
    DateTime? startedAt,
    DateTime? submittedAt,
    Map<String, dynamic>? answers,
    int? score,
    int? totalPossiblePoints,
    double? percentage,
    bool? passed,
    bool? isAutoGraded,
    String? feedback,
  }) {
    return QuizAttemptEntity(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentAvatar: studentAvatar ?? this.studentAvatar,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      totalPossiblePoints: totalPossiblePoints ?? this.totalPossiblePoints,
      percentage: percentage ?? this.percentage,
      passed: passed ?? this.passed,
      isAutoGraded: isAutoGraded ?? this.isAutoGraded,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        id,
        quizId,
        studentId,
        studentName,
        studentAvatar,
        startedAt,
        submittedAt,
        answers,
        score,
        totalPossiblePoints,
        percentage,
        passed,
        isAutoGraded,
        feedback,
      ];
}

class QuizSummaryStatsEntity extends Equatable {
  final String quizId;
  final int totalSubmissions;
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final double passRatePercentage;

  const QuizSummaryStatsEntity({
    required this.quizId,
    required this.totalSubmissions,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.passRatePercentage,
  });

  @override
  List<Object?> get props => [
        quizId,
        totalSubmissions,
        averageScore,
        highestScore,
        lowestScore,
        passRatePercentage,
      ];
}
