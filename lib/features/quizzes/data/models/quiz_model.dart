import '../../domain/entities/quiz_entity.dart';

class QuizQuestionModel extends QuizQuestionEntity {
  const QuizQuestionModel({
    required super.id,
    required super.quizId,
    required super.prompt,
    required super.type,
    super.options = const [],
    super.correctAnswer,
    super.correctOptionIndices = const [],
    super.explanation = '',
    super.points = 1,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String? ?? '',
      quizId: json['quizId'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      type: QuestionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => QuestionType.singleChoice,
      ),
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctAnswer: json['correctAnswer'],
      correctOptionIndices: (json['correctOptionIndices'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      explanation: json['explanation'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'prompt': prompt,
      'type': type.name,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctOptionIndices': correctOptionIndices,
      'explanation': explanation,
      'points': points,
    };
  }

  factory QuizQuestionModel.fromEntity(QuizQuestionEntity entity) {
    return QuizQuestionModel(
      id: entity.id,
      quizId: entity.quizId,
      prompt: entity.prompt,
      type: entity.type,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      correctOptionIndices: entity.correctOptionIndices,
      explanation: entity.explanation,
      points: entity.points,
    );
  }
}

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.courseId,
    required super.courseCode,
    required super.courseTitle,
    required super.title,
    required super.description,
    required super.timeLimitMinutes,
    required super.totalPoints,
    super.passingPercentage = 70.0,
    super.maxAttempts = 1,
    super.isPublished = true,
    super.shuffleQuestions = false,
    super.allowReview = true,
    required super.availableFrom,
    required super.dueDate,
    required super.questionsCount,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      courseCode: json['courseCode'] as String? ?? '',
      courseTitle: json['courseTitle'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timeLimitMinutes: (json['timeLimitMinutes'] as num?)?.toInt() ?? 15,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 100,
      passingPercentage:
          (json['passingPercentage'] as num?)?.toDouble() ?? 70.0,
      maxAttempts: (json['maxAttempts'] as num?)?.toInt() ?? 1,
      isPublished: json['isPublished'] as bool? ?? true,
      shuffleQuestions: json['shuffleQuestions'] as bool? ?? false,
      allowReview: json['allowReview'] as bool? ?? true,
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'] as String)
          : DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      questionsCount: (json['questionsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'title': title,
      'description': description,
      'timeLimitMinutes': timeLimitMinutes,
      'totalPoints': totalPoints,
      'passingPercentage': passingPercentage,
      'maxAttempts': maxAttempts,
      'isPublished': isPublished,
      'shuffleQuestions': shuffleQuestions,
      'allowReview': allowReview,
      'availableFrom': availableFrom.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'questionsCount': questionsCount,
    };
  }

  factory QuizModel.fromEntity(QuizEntity entity) {
    return QuizModel(
      id: entity.id,
      courseId: entity.courseId,
      courseCode: entity.courseCode,
      courseTitle: entity.courseTitle,
      title: entity.title,
      description: entity.description,
      timeLimitMinutes: entity.timeLimitMinutes,
      totalPoints: entity.totalPoints,
      passingPercentage: entity.passingPercentage,
      maxAttempts: entity.maxAttempts,
      isPublished: entity.isPublished,
      shuffleQuestions: entity.shuffleQuestions,
      allowReview: entity.allowReview,
      availableFrom: entity.availableFrom,
      dueDate: entity.dueDate,
      questionsCount: entity.questionsCount,
    );
  }
}

class QuizAttemptModel extends QuizAttemptEntity {
  const QuizAttemptModel({
    required super.id,
    required super.quizId,
    required super.studentId,
    required super.studentName,
    super.studentAvatar,
    required super.startedAt,
    super.submittedAt,
    super.answers = const {},
    required super.score,
    required super.totalPossiblePoints,
    required super.percentage,
    required super.passed,
    super.isAutoGraded = true,
    super.feedback,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptModel(
      id: json['id'] as String? ?? '',
      quizId: json['quizId'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      studentAvatar: json['studentAvatar'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      answers: (json['answers'] as Map<String, dynamic>?) ?? const {},
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalPossiblePoints:
          (json['totalPossiblePoints'] as num?)?.toInt() ?? 100,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      passed: json['passed'] as bool? ?? false,
      isAutoGraded: json['isAutoGraded'] as bool? ?? true,
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'studentId': studentId,
      'studentName': studentName,
      'studentAvatar': studentAvatar,
      'startedAt': startedAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'answers': answers,
      'score': score,
      'totalPossiblePoints': totalPossiblePoints,
      'percentage': percentage,
      'passed': passed,
      'isAutoGraded': isAutoGraded,
      'feedback': feedback,
    };
  }

  factory QuizAttemptModel.fromEntity(QuizAttemptEntity entity) {
    return QuizAttemptModel(
      id: entity.id,
      quizId: entity.quizId,
      studentId: entity.studentId,
      studentName: entity.studentName,
      studentAvatar: entity.studentAvatar,
      startedAt: entity.startedAt,
      submittedAt: entity.submittedAt,
      answers: entity.answers,
      score: entity.score,
      totalPossiblePoints: entity.totalPossiblePoints,
      percentage: entity.percentage,
      passed: entity.passed,
      isAutoGraded: entity.isAutoGraded,
      feedback: entity.feedback,
    );
  }
}

class QuizSummaryStatsModel extends QuizSummaryStatsEntity {
  const QuizSummaryStatsModel({
    required super.quizId,
    required super.totalSubmissions,
    required super.averageScore,
    required super.highestScore,
    required super.lowestScore,
    required super.passRatePercentage,
  });

  factory QuizSummaryStatsModel.fromJson(Map<String, dynamic> json) {
    return QuizSummaryStatsModel(
      quizId: json['quizId'] as String? ?? '',
      totalSubmissions: (json['totalSubmissions'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      highestScore: (json['highestScore'] as num?)?.toInt() ?? 0,
      lowestScore: (json['lowestScore'] as num?)?.toInt() ?? 0,
      passRatePercentage:
          (json['passRatePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'totalSubmissions': totalSubmissions,
      'averageScore': averageScore,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
      'passRatePercentage': passRatePercentage,
    };
  }
}
