# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.9.0] - 2026-09-06 — Quizzes, Interactive Exams & Assessment Engine

### Added
- Domain Layer:
  - `QuestionType` (`singleChoice`, `multipleChoice`, `trueFalse`, `shortAnswer`), `QuizQuestionEntity`, `QuizEntity`, `QuizAttemptEntity`, and `QuizSummaryStatsEntity`.
  - `QuizRepository` contract covering quiz catalog listings, course filtering, active/archived state, quiz authoring/creation, live exam submissions, automatic grading, attempt scorecards, and assessment analytics.
- Data Layer:
  - `QuizQuestionModel`, `QuizModel`, `QuizAttemptModel`, and `QuizSummaryStatsModel` with full Firestore & JSON serialization/deserialization.
  - `QuizRemoteDataSource` and `QuizRemoteDataSourceImpl` pre-seeded with multi-discipline question banks across CS101, CS201, and MATH301, instant auto-grading algorithms, attempt logs, and cohort performance statistics.
  - `QuizRepositoryImpl` connecting domain use cases with robust `ServerException` error handling.
- State Management:
  - `QuizListCubit` & `QuizListState` with real-time course filters, search queries, status tabs (All, Published, Draft, Closed), and quiz creation.
  - `QuizDetailCubit` & `QuizDetailState` orchestrating quiz details, rules, allowed attempts, past attempt scorecards, and exam prerequisites.
  - `QuizExamSessionCubit` & `QuizExamSessionState` driving the live exam experience: synchronized countdown timer, question navigation palette, question response staging (single-choice, multiple-choice, true/false, short answer text), question bookmark/flagging, and auto-submit upon timer expiration.
  - `QuizBuilderCubit` & `QuizBuilderState` supporting faculty exam creation with dynamic question adding, option management, auto-calculated total points, and parameter configuration (duration, passing score, shuffle, attempt limits).
  - `QuizAnalyticsCubit` & `QuizAnalyticsState` computing class averages, median scores, pass rates, question difficulty analysis, student score distribution rosters, and CSV exports.
- Presentation Components & Screens:
  - `QuizCard`: Adaptive catalog card with course badge, question count, point tally, time duration, and status indicators.
  - `ExamTimerWidget`: Urgency-aware live countdown indicator with color-coded warning thresholds and tabular MM:SS time display.
  - `QuestionPaletteWidget`: Interactive question matrix indicating answered, unanswered, flagged, and currently active questions for quick jumping.
  - `QuestionViewCard`: Dynamic question renderer with styled options for single-choice, multiple-choice, boolean true/false, and short answer inputs.
  - `QuizResultCard`: Comprehensive assessment scorecard featuring score percentage gauge, pass/fail status badge, and detailed question-by-question review with answer keys and explanations.
  - `QuizListScreen`: Unified assessment catalog with search, course filters, status tabs, and faculty builder launcher.
  - `QuizDetailScreen`: Pre-exam overview screen with exam instructions, syllabus topic tags, and student attempt histories.
  - `QuizExamScreen`: Fullscreen focused exam hall with sticky timer header, question view, side palette, flag toggles, and submission confirmation modal.
  - `QuizBuilderScreen`: Interactive authoring studio for creating exams with dynamic question bank builders and instant point calculations.
  - `QuizAnalyticsScreen`: Faculty dashboard with grade metrics, score distribution breakdown, student roster table, and CSV report export.
- Routing & Navigation Integration:
  - Added routes `RouteConstants.quizzes` (`/quizzes`), `quizzesCreate` (`/quizzes/create`), `quizDetail` (`/quizzes/:id`), `quizTake` (`/quizzes/:id/take`), and `quizAnalytics` (`/quizzes/:id/analytics`).
  - Added `Quizzes` item to primary navigation sidebar and mobile drawer in `PortalNavigationShell`.
  - Registered `QuizRepository` and all 5 cubits (`QuizListCubit`, `QuizDetailCubit`, `QuizExamSessionCubit`, `QuizBuilderCubit`, `QuizAnalyticsCubit`) in `AcademicPortalApp` root provider tree.
- Quality Assurance:
  - 15 comprehensive unit and widget tests in `test/quizzes_test.dart` verifying data sources, scoring logic, attempt calculation, and presentation widgets.
  - 70/70 tests passing cleanly across the entire project test suite (`flutter test`).
  - 0 static analysis issues (`flutter analyze` with 0 warnings/errors).
  - Verified production build with `flutter build web --release`.

## [v0.8.0] - 2026-09-06 — Live Attendance & QR Code Check-in System

### Added
- Domain Layer:
  - `AttendanceSessionEntity`, `AttendanceRecordEntity`, `StudentAttendanceSummaryEntity`, `AttendanceStatus`, and `CheckInMethod`.
  - `AttendanceRepository` contract covering session lifecycles (start, get active, expire, get course sessions), real-time student check-ins (QR code verification & 6-digit fallback PIN), faculty manual roster overrides, roster queries, and student attendance statistics.
- Data Layer:
  - `AttendanceSessionModel`, `AttendanceRecordModel`, and `StudentAttendanceSummaryModel` with comprehensive JSON & Firestore serialization / deserialization.
  - `AttendanceRemoteDataSource` and `AttendanceRemoteDataSourceImpl` pre-seeded with realistic lectures (CS101, CS201, MATH301), active dynamically rotating QR tokens, cryptographic 6-digit PINs, full student rosters with check-in timestamps, and summary statistics.
  - `AttendanceRepositoryImpl` connecting data layer to domain contracts with robust `ServerException` error handling.
- State Management:
  - `AttendanceSessionCubit` & `AttendanceSessionState` managing active lecture session lifecycles, real-time expiry countdowns, dynamic QR rotation, and session completion.
  - `AttendanceRosterCubit` & `AttendanceRosterState` supporting real-time student roster updates, search filters, status tabs (Present, Late, Excused, Absent), manual status overrides, and CSV export.
  - `StudentCheckInCubit` & `StudentCheckInState` handling QR token scanning and fallback 6-digit PIN verification.
  - `StudentAttendanceHistoryCubit` & `StudentAttendanceHistoryState` tracking course-by-course attendance rates, session journals, and absence alert warnings.
- Presentation Components & Screens:
  - `PortalQrWidget`: Pure Flutter Canvas QR matrix renderer with finder patterns, quiet zones, and animated expiry progress ring.
  - `SessionQrDisplayCard`: Instructor lecture projector display featuring live countdown timer, rotating QR code, large 6-digit fallback PIN with copy button, and live turnout progress bar.
  - `QrScannerDialog`: Student check-in modal featuring animated laser scanline viewfinder, camera switcher simulation, and seamless 6-digit fallback PIN input.
  - `AttendanceRecordTile`: Student roster item with status pill, check-in method badge, timestamp, and faculty override actions.
  - `AttendanceStatsSummaryCard`: Attendance rate gauge, breakdown chips, and at-risk academic standing alert banner.
  - `AttendanceScreen`: Dual-role adaptive hub for faculty projector/archives and student check-in/journal.
  - `SessionDetailScreen`: Deep-dive session roster with status filters, search, manual override, and CSV export.
- Cross-Feature Routing & Shell Integration:
  - Added routes `RouteConstants.attendance` (`/attendance`) and `RouteConstants.attendanceSession` (`/attendance/session/:id`).
  - Added `Attendance` navigation destination in `PortalNavigationShell`.
  - Registered `AttendanceRepository` and all 4 cubits in `AcademicPortalApp` root providers.
  - Connected `Attendance Rate` metric card on student dashboard and `Average Attendance` metric card on instructor dashboard directly to the attendance hub.
- Quality Assurance:
  - Comprehensive unit and widget tests in `test/attendance_test.dart` (55 total project tests passing cleanly across the entire suite).
  - 0 static analysis issues on `flutter analyze`.
  - Web production compilation verified with `flutter build web --release`.

## [v0.7.0] - 2026-09-05 — Assignment Submission & Grading System

### Added
- Domain Layer:
  - `AssignmentEntity`, `AssignmentRubricItem`, `RubricLevel`, `SubmissionEntity`, `RubricScore`, `GradebookEntry`, and `CourseGradebook`.
  - `AssignmentRepository` contract covering course assignment retrieval, student submission management, rubric grading, and gradebook calculation.
- Data Layer:
  - `AssignmentModel`, `AssignmentRubricItemModel`, `RubricLevelModel`, `SubmissionModel`, and `RubricScoreModel` with Firestore / JSON serialization and deserialization.
  - `AssignmentRemoteDataSource` and `AssignmentRemoteDataSourceImpl` with pre-seeded assignments (CS101, CS201, MATH301), multi-level rubrics, diverse submissions (graded, needs grading, pending), and gradebook aggregates.
  - `AssignmentRepositoryImpl` with robust error handling and domain entity mapping.
- State Management:
  - `AssignmentListCubit` & `AssignmentListState` supporting real-time search, course code filtering, status tabs, and assignment creation.
  - `AssignmentDetailCubit` & `AssignmentDetailState` coordinating assignment details and student submissions.
  - `SubmissionCubit` & `SubmissionState` handling file upload simulation, text responses, and submission validation.
  - `GradingCubit` & `GradingState` driving instructor rubric matrix scoring, constructive feedback, and publishing.
  - `GradebookCubit` & `GradebookState` calculating class averages, high/low scores, and weighted letter grade rosters.
- Presentation Components & Screens:
  - `AssignmentCard`: Adaptive card with course badge, weight pill, relative deadline countdown, and contextual action buttons.
  - `SubmissionItemCard`: Submissions queue card with student avatar, attachment details, and grading launcher.
  - `RubricScoringWidget`: Interactive multi-tier rubric evaluation and review widget.
  - `GradeSummaryCard`: Visual evaluation summary featuring letter grade badge, progress bar, and instructor comments.
  - `AssignmentListScreen`: Dual-role assignments command center featuring search, course filters, status tabs, and assignment creation modal.
  - `AssignmentDetailScreen`: Deep overview with instructions, attachments, rubric review, and student submission portal.
  - `AssignmentGradingScreen`: Instructor grading cockpit with student switcher, deliverable previews, rubric matrix, and publish controls.
  - `CourseGradebookScreen`: Course gradebook matrix with class average KPIs, student roster table, and CSV export.
- Cross-Feature Routing & Shell Integration:
  - Added routes `RouteConstants.assignments`, `RouteConstants.assignmentDetail`, `RouteConstants.assignmentGrading`, and `RouteConstants.gradebook`.
  - Added `Assignments` tab to `PortalNavigationShell.defaultNavItems`.
  - Integrated `AssignmentRepository` and all 5 cubits into `AcademicPortalApp` root providers.
  - Linked student dashboard deadlines and instructor grading queue directly to assignment screens.
- Quality Assurance:
  - Comprehensive unit and widget tests in `test/assignments_test.dart` (44 total project tests passing cleanly across the entire suite).
  - 0 static analysis issues on `flutter analyze`.
  - Production web compilation verified with `flutter build web --release`.

## [v0.6.0] - 2026-09-05 — Student Portal & Course Enrollment

### Added
- Domain Layer:
  - `EnrollmentEntity`, `EnrollmentStatus`, `StudentDashboardStats`, `StudentScheduleItem`, `StudentDeadlineEntity`, and `DayOfWeek`.
  - `EnrollmentRepository` contract with enrollment, drop, grade check, weekly timetable queries, and academic standing stats.
- Data Layer:
  - `EnrollmentModel` with Firestore and JSON serialization / deserialization.
  - `EnrollmentRemoteDataSource` & `EnrollmentRemoteDataSourceImpl` with pre-seeded demo student schedules, enrolled courses, assignment deadlines, and seat limit tracking.
  - `EnrollmentRepositoryImpl` connecting data layer to domain contracts with robust error handling.
- State Management:
  - `EnrollmentCubit` & `EnrollmentState` (`Initial`, `Loading`, `Loaded`, `Enrolling`, `Enrolled`, `Dropping`, `Dropped`, `Error`) supporting real-time course enrollments, seat availability, credit checks, and drop actions.
  - `StudentDashboardCubit` & `StudentDashboardState` (`Initial`, `Loading`, `Loaded`, `Error`) aggregating GPA, enrolled credits, attendance rate, weekly schedule timetable, and upcoming deadlines.
- Presentation Components & Screens:
  - `StudentScheduleCard`: Weekly timetable card with time badge, course code, venue, and live session pulse indicator.
  - `EnrolledCourseCard`: Course enrollment card with instructor info, credits pill, grade pill, current status, attendance badge, and drop action.
  - `StudentDeadlineCard`: Deadline reminder component showing due dates, urgency badge (urgent, impending, upcoming), and submission status.
  - `StudentDashboardScreen`: Adaptive command center featuring student greeting, academic standing pill, 4 key KPI cards (GPA, Enrolled Credits / Max, Active Courses, Attendance Rate), weekly schedule timetable, current enrolled courses list with drop dialogs, and pending assignment deadlines.
- Cross-Feature Course Catalog Integration:
  - `CourseCard`: Dynamic "Enroll" / "Enrolled" / "Drop" action buttons based on live student enrollment state, credit checks, and section capacity.
  - `CourseDetailScreen`: Direct course enrollment button with instant status feedback, credit check validation, and drop confirmation modal.
  - `PortalNavigationShell`: Role-adaptive navigation dynamically routing students to `/student-dashboard` and instructors to `/instructor-dashboard`.
- Routing & Dependency Injection:
  - Added `RouteConstants.studentDashboard` (`/student-dashboard`) to router and top-level providers.
  - Registered `EnrollmentRepository`, `EnrollmentCubit`, and `StudentDashboardCubit` in app-level providers.
- Quality Assurance:
  - Comprehensive unit and widget tests in `test/student_portal_test.dart` (33 total project tests passing cleanly across the entire suite).
  - 0 static analysis issues on `flutter analyze`.
  - Production web compilation verified with `flutter build web --release`.

## [v0.5.0] - 2026-09-05 — Course Management

### Added
- Domain Layer:
  - `CourseEntity`, `SyllabusItem`, and `CourseSection` domain entities.
  - `CourseRepository` abstract contract for querying catalog, searching, filtering, creating, and updating courses.
- Data Layer:
  - `CourseModel` and `SyllabusItemModel` with Firestore and JSON serialization / deserialization.
  - `CourseRemoteDataSource` and `CourseRemoteDataSourceImpl` with pre-seeded demo curriculum and cloud Firestore integration.
  - `CourseRepositoryImpl` with robust error handling and domain mapping.
- State Management:
  - `CoursesCubit` & `CoursesState` (`Initial`, `Loading`, `Loaded`, `Error`) supporting real-time search, department filtering, and course detail caching.
  - `CourseFormCubit` & `CourseFormState` (`Initial`, `Submitting`, `Success`, `Failure`) for multi-section course creation.
- Course Presentation & Components:
  - `CourseCard`: Adaptive card component displaying department tag, term badge, enrolled/capacity pill, credits indicator, instructor avatar, schedule, and view details action.
  - `CourseListScreen`: Responsive course catalog featuring search bar, quick department filter chips (All, CS, Math, Physics, Engineering), grid view, and instructor course creation launcher.
  - `CourseCreateScreen`: Multi-section course creation wizard including basic details, department and term selectors, schedule and capacity parameters, and dynamic syllabus module builder with week-by-week topic configuration.
  - `CourseDetailScreen`: Deep-dive course overview featuring tabs for Syllabus breakdown (accordion cards with topics and duration) and Section Roster with live enrollment statistics and student listing.
- Navigation Shell & Dashboard Integration:
  - Routes `RouteConstants.courses` (`/courses`), `RouteConstants.courseCreate` (`/courses/create`), and `RouteConstants.courseDetail` (`/courses/:id`).
  - Added Courses destination to `PortalNavigationShell` (desktop navigation rail & mobile bottom navigation bar).
  - Connected quick actions and course management links from `InstructorDashboardScreen` directly to the course catalog and course creation wizard.
- Quality Assurance:
  - Comprehensive unit and widget test suite in `test/courses_test.dart` (25 total project tests passing cleanly).
  - Clean static analysis with 0 issues (`flutter analyze`).
  - Release web bundle compilation verified (`flutter build web --release`).

## [v0.4.0] - 2026-09-05 — Instructor Dashboard

### Added
- Domain entities: `InstructorDashboardStats`, `CourseSummaryEntity`, `RecentActivityEntity`, and `UpcomingDeadlineEntity`.
- Repository layer: `InstructorDashboardRepository` and `InstructorDashboardRepositoryImpl` backed by `InstructorDashboardRemoteDataSource` with Firestore integration and offline mock fallbacks.
- State Management: `InstructorDashboardCubit` and `InstructorDashboardState` (`Initial`, `Loading`, `Loaded`, `Error`) with parallel async loading and pull-to-refresh support.
- KPI & Course Components:
  - `MetricCard`: KPI component with icon badge, numerical counters, subtitle, and trend pill indicators.
  - `CourseOverviewCard`: Card displaying course code, enrolled student tally, course title, schedule, room, department, and manage actions.
- Instructor Command Center:
  - `InstructorDashboardScreen`: Responsive command center featuring greeting header banner, quick course creation action, 4 KPI metric cards, assigned course grid, live student activity feed, and grading queue deadline breakdown.
- Navigation Shell & Routing Integration:
  - Route constants `RouteConstants.dashboard` and `RouteConstants.instructorDashboard` (`/instructor-dashboard`).
  - GoRouter routing connected to `InstructorDashboardScreen`.
  - `PortalNavigationShell` updated with `Dashboard` destination tab and automatic route resolution.
  - Quick-launch navigation added to `FoundationScreen` hero banner.
- Quality Assurance:
  - Unit and widget test suite in `test/instructor_dashboard_test.dart` (19 total project tests passing cleanly).
  - Production web bundle compiled (`flutter build web --release`).

## [v0.3.0] - 2026-09-05 — Authentication

### Added
- Domain entity `UserEntity` and `UserRole` (`Instructor`, `Student`) defining role permissions.
- `AuthRepository` and `AuthRepositoryImpl` with `FirebaseAuth` integration and fallback persistence.
- `UserModel` data transfer object with Firestore and JSON serialization.
- `AuthCubit` state management handling registration, login, logout, and session state emissions.
- Modern `LoginScreen` with form validation, password visibility toggle, error notifications, and quick demo credentials shortcuts.
- `RegisterScreen` featuring visual academic role selector (`Instructor` vs `Student`), field validations, and confirmation matching.
- Protected route redirection guards in `AppRouter` based on active authentication state.
- Dynamic user profile pill and role badges in `PortalNavigationShell` header with quick sign-out.
- Comprehensive unit and widget tests for authentication flows (13 total test cases passing).

### Technical Details
- Zero static analysis or lint warnings (`flutter analyze`).
- Web release compilation verified (`flutter build web --release`).

## [v0.2.0] - 2026-09-05 — Design System

### Added
- Standardized design system tokens for multi-layered elevation shadows (`AppShadows`) and micro-interaction animations (`AppAnimations`).
- Reusable atomic UI components:
  - `PortalButton`: High-performance button supporting `primary`, `secondary`, `outline`, `ghost`, and `destructive` variants with integrated loading states and tap-scale feedback.
  - `PortalCard`: Animated surface container with elevation lift on hover and border highlight.
  - `PortalBadge`: Semantic status, role indicators (`Instructor`, `Student`), and category tags with dot and icon options.
  - `PortalAvatar`: User profile avatar with initials parsing, image fallback, and online presence indicator.
- Form controls:
  - `PortalTextField`: Validated input field supporting floating labels, search variants, and password obfuscation toggles.
- Loading and Empty State indicators:
  - `PortalSkeleton`: Smooth shimmer animation for cards, circular avatars, and text lines.
  - `PortalEmptyState`: Clean illustrated component for empty collections with call-to-action button.
- Adaptive Layout & Shell:
  - `PortalNavigationShell`: Responsive shell with desktop navigation rail, tablet collapsed rail, mobile bottom navigation bar, and integrated theme toggle.
- Interactive Component Showcase:
  - `DesignSystemScreen` accessible at `/design-system` for visual component testing across light and dark themes.
- Automated widget test suite covering button interactions, text field inputs, badge rendering, avatar initials, and skeleton shimmers.

### Technical Details
- 9 total tests passing cleanly (`flutter test`).
- 0 lint or static analysis issues (`flutter analyze`).
- Production web bundle compiled (`flutter build web --release`).

## [v0.1.0] - 2026-09-05 — Project Foundation

### Added
- Feature-based Clean Architecture structure (`core/`, `app/`, `features/`).
- Cross-platform Firebase foundation with safe fallback handling for Web, Mobile, and Desktop.
- GoRouter declarative routing system with `/`, `/foundation`, 404 error page, and placeholder navigation.
- BLoC state management foundation with `AppBlocObserver` and `ThemeCubit` for dynamic theme switching (System / Light / Dark).
- Design System tokens: Oxford Sapphire, Slate, Midnight Dark palettes, and Google Fonts typography (Outfit & Inter).
- Responsive breakpoint layout utilities (`Breakpoint`, `ResponsiveLayout`, `ResponsiveBuilder`, and `ResponsiveContextExtensions`).
- Interactive Foundation Status screen showcasing responsive behavior, theme toggling, and architectural health.
- Automated widget and unit tests validating startup, responsive breakpoints, and theme transitions.

### Technical Details
- Dart SDK: `^3.9.0`
- Flutter Web release build verified (`build/web`).
- Zero analysis issues on `flutter analyze`.
