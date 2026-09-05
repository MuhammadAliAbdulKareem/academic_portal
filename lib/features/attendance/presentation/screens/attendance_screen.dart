import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/attendance_session_cubit.dart';
import '../cubit/attendance_session_state.dart';
import '../cubit/student_attendance_history_cubit.dart';
import '../cubit/student_attendance_history_state.dart';
import '../widgets/attendance_record_tile.dart';
import '../widgets/attendance_stats_summary_card.dart';
import '../widgets/qr_scanner_dialog.dart';
import '../widgets/session_qr_display_card.dart';

/// Central Attendance Hub providing adaptive workflows for Faculty & Students.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCourseId = 'course-cs101';
  late TabController _studentTabController;

  final Map<String, String> _courses = {
    'course-cs101': 'CS101: Intro to CS',
    'course-cs201': 'CS201: Data Structures',
    'course-math301': 'MATH301: Linear Algebra',
  };

  @override
  void initState() {
    super.initState();
    _studentTabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _studentTabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final authState = context.read<AuthCubit>().state;
    final isInstructor =
        authState is Authenticated && authState.user.role == UserRole.instructor;
    final studentId = authState is Authenticated ? authState.user.id : 'user-student-1';

    if (isInstructor) {
      context.read<AttendanceSessionCubit>().loadSessions(_selectedCourseId);
    } else {
      context.read<AttendanceSessionCubit>().loadSessions(_selectedCourseId);
      context.read<StudentAttendanceHistoryCubit>().loadHistory(studentId: studentId);
    }
  }

  void _onCourseChanged(String? newId) {
    if (newId == null || newId == _selectedCourseId) return;
    setState(() {
      _selectedCourseId = newId;
    });
    context.read<AttendanceSessionCubit>().loadSessions(newId);
  }

  void _showStartSessionDialog(BuildContext context) {
    final titleController = TextEditingController(
      text: 'Lecture ${DateTime.now().day}: Advanced System Architecture',
    );
    final roomController = TextEditingController(text: 'Turing Hall 302');
    final sectionController = TextEditingController(text: 'Section 01');
    int duration = 15;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_task_rounded,
                      color: AppColors.primaryLight, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Start Attendance Session'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Configure live check-in parameters for ${_courses[_selectedCourseId]}:',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Lecture / Session Topic',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: sectionController,
                          decoration: const InputDecoration(
                            labelText: 'Section',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: roomController,
                          decoration: const InputDecoration(
                            labelText: 'Room / Venue',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: duration,
                    decoration: const InputDecoration(
                      labelText: 'Session Expiry Window',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 minutes (Express)')),
                      DropdownMenuItem(value: 10, child: Text('10 minutes')),
                      DropdownMenuItem(value: 15, child: Text('15 minutes (Standard)')),
                      DropdownMenuItem(value: 30, child: Text('30 minutes')),
                      DropdownMenuItem(value: 60, child: Text('60 minutes (Full Class)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => duration = val);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final title = titleController.text.trim();
                  final room = roomController.text.trim();
                  final section = sectionController.text.trim();
                  if (title.isEmpty) return;

                  final courseCode = _courses[_selectedCourseId]?.split(':').first ?? 'CS101';
                  final courseTitle = _courses[_selectedCourseId]?.split(':').last.trim() ?? 'Course';

                  Navigator.of(dialogCtx).pop();

                  context.read<AttendanceSessionCubit>().startNewSession(
                        courseId: _selectedCourseId,
                        courseCode: courseCode,
                        courseTitle: courseTitle,
                        section: section.isNotEmpty ? section : 'Section 01',
                        title: title,
                        room: room.isNotEmpty ? room : 'Hall 101',
                        durationMinutes: duration,
                      );
                },
                icon: const Icon(Icons.qr_code_rounded, size: 18),
                label: const Text('Generate QR & Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isInstructor =
        authState is Authenticated && authState.user.role == UserRole.instructor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final horizontalPadding = sizingInfo.isDesktop ? 32.0 : 16.0;

        return Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar
                    _buildHeader(context, isInstructor, isDark, sizingInfo),
                    const SizedBox(height: 24),

                    // Role-Specific Views
                    if (isInstructor)
                      _buildInstructorView(context, isDark, sizingInfo)
                    else
                      _buildStudentView(context, authState, isDark, sizingInfo),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isInstructor,
    bool isDark,
    ResponsiveInfo sizingInfo,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.primaryLight,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Attendance & Check-In',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isInstructor
                      ? 'Launch live lecture check-in QR codes, verify turnouts, and manage rosters.'
                      : 'Scan class QR codes, submit PINs, and track your attendance record.',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (isInstructor)
              ElevatedButton.icon(
                onPressed: () => _showStartSessionDialog(context),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Start Live Check-In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructorView(
    BuildContext context,
    bool isDark,
    ResponsiveInfo sizingInfo,
  ) {
    return BlocConsumer<AttendanceSessionCubit, AttendanceSessionState>(
      listener: (context, state) {
        if (state is AttendanceSessionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AttendanceSessionLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AttendanceSessionLoaded) {
          final activeSession = state.activeSession;
          final pastSessions = state.allSessions.where((s) => !s.isActive).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Course Filter Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 20, color: AppColors.primaryLight),
                    const SizedBox(width: 12),
                    const Text('Course: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCourseId,
                          isExpanded: true,
                          items: _courses.entries.map((e) {
                            return DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            );
                          }).toList(),
                          onChanged: _onCourseChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active Session Projector Card (if active)
              if (activeSession != null) ...[
                SessionQrDisplayCard(
                  session: activeSession,
                  isCompact: !sizingInfo.isDesktop,
                  onEndSession: () {
                    context.read<AttendanceSessionCubit>().endSession(activeSession.id);
                  },
                  onViewRoster: () {
                    context.push('/attendance/session/${activeSession.id}');
                  },
                ),
                const SizedBox(height: 32),
              ],

              // Past Sessions Archive Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session History & Archive (${pastSessions.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (pastSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history_toggle_off_rounded,
                            size: 48,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'No completed sessions for this course yet.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pastSessions.length,
                  itemBuilder: (context, index) {
                    final s = pastSessions[index];
                    final turnout = s.attendanceRate;
                    final isGood = turnout >= 75;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isGood ? AppColors.success : AppColors.warning)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              color: isGood ? AppColors.success : AppColors.warning,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${s.courseCode} • ${s.section} • ${s.room} • ${s.startTime.month}/${s.startTime.day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextMuted
                                        : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${s.attendedCount} / ${s.totalEnrolled}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${turnout.toStringAsFixed(0)}% Turnout',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isGood ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () {
                              context.push('/attendance/session/${s.id}');
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Roster'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStudentView(
    BuildContext context,
    AuthState authState,
    bool isDark,
    ResponsiveInfo sizingInfo,
  ) {
    final studentId = authState is Authenticated ? authState.user.id : 'user-student-1';
    final studentName = authState is Authenticated ? authState.user.displayName : 'Alex Rivera';
    final studentEmail = authState is Authenticated ? authState.user.email : 'student@academicportal.edu';
    final studentAvatar = authState is Authenticated ? authState.user.photoUrl : null;

    final sessionState = context.watch<AttendanceSessionCubit>().state;
    final activeSession =
        sessionState is AttendanceSessionLoaded ? sessionState.activeSession : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Check-in Action Banner (If active session available)
        if (activeSession != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'OPEN NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activeSession.courseCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeSession.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Room: ${activeSession.room} • Section: ${activeSession.section}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    QrScannerDialog.show(
                      context,
                      session: activeSession,
                      studentId: studentId,
                      studentName: studentName,
                      studentEmail: studentEmail,
                      studentAvatar: studentAvatar,
                      onCheckInSuccess: () {
                        context.read<StudentAttendanceHistoryCubit>().loadHistory(studentId: studentId);
                      },
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Check In (QR / PIN)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryLight, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No Active Class Sessions Currently Open',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'When your instructor opens class attendance, a live check-in prompt will appear here.',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 28),

        // Tabs: Course Attendance Overview vs My Attendance Timeline
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: TabBar(
            controller: _studentTabController,
            indicator: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            tabs: const [
              Tab(text: 'Course Attendance Rates'),
              Tab(text: 'My Attendance Journal'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        BlocBuilder<StudentAttendanceHistoryCubit, StudentAttendanceHistoryState>(
          builder: (context, state) {
            if (state is StudentAttendanceHistoryLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is StudentAttendanceHistoryLoaded) {
              return AnimatedBuilder(
                animation: _studentTabController,
                builder: (context, _) {
                  if (_studentTabController.index == 0) {
                    // Course Rate Cards Grid
                    final isGrid = sizingInfo.isDesktop || sizingInfo.isTablet;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isGrid)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 180,
                            ),
                            itemCount: state.courseSummaries.length,
                            itemBuilder: (context, index) {
                              return AttendanceStatsSummaryCard(
                                summary: state.courseSummaries[index],
                              );
                            },
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.courseSummaries.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: AttendanceStatsSummaryCard(
                                  summary: state.courseSummaries[index],
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  } else {
                    // Chronological Attendance Log
                    if (state.allRecords.isEmpty) {
                      return Center(
                        child: Text(
                          'No attendance records found.',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.allRecords.length,
                      itemBuilder: (context, index) {
                        return AttendanceRecordTile(
                          record: state.allRecords[index],
                          isInstructor: false,
                        );
                      },
                    );
                  }
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
