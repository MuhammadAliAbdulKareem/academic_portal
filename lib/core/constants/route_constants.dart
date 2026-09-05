/// Canonical route path constants for GoRouter.
class RouteConstants {
  RouteConstants._();

  static const String root = '/';
  static const String foundation = '/foundation';
  static const String designSystem = '/design-system';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String instructorDashboard = '/instructor-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String courses = '/courses';
  static const String courseCreate = '/courses/create';
  static const String courseDetail = '/courses/:id';
  static const String assignments = '/assignments';
  static const String assignmentDetail = '/assignments/:id';
  static const String assignmentGrading = '/assignments/:id/grade';
  static const String gradebook = '/courses/:id/gradebook';
  static const String attendance = '/attendance';
  static const String attendanceSessionDetail = '/attendance/session/:id';
  static const String quizzes = '/quizzes';
  static const String quizDetail = '/quizzes/:id';
  static const String quizExam = '/quizzes/:id/take';
  static const String quizBuilder = '/quizzes/create';
  static const String quizAnalytics = '/quizzes/:id/analytics';
  static const String notFound = '/404';
}
