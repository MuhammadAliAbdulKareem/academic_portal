import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/layout/portal_navigation_shell.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/attendance_entity.dart';
import '../cubit/attendance_roster_cubit.dart';
import '../cubit/attendance_roster_state.dart';
import '../widgets/attendance_record_tile.dart';

/// Deep-dive roster screen for an attendance session with search, filtering & overrides.
class SessionDetailScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  AttendanceStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceRosterCubit>().loadRoster(widget.sessionId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _exportCsv(BuildContext context, List<AttendanceRecordEntity> records) {
    final buffer = StringBuffer();
    buffer.writeln('Student ID,Student Name,Email,Status,Check-In Time,Method,Notes');
    for (final r in records) {
      buffer.writeln(
        '"${r.studentId}","${r.studentName}","${r.studentEmail}","${r.status.displayName}","${r.checkInTime?.toIso8601String() ?? 'N/A'}","${r.checkInMethod?.displayName ?? 'N/A'}","${r.notes ?? ''}"',
      );
    }

    final csvContent = buffer.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.table_view_rounded, color: AppColors.primaryLight),
            SizedBox(width: 10),
            Text('Export Attendance CSV'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Copy or export the official session attendance log for registrar reports:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  csvContent,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance CSV copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PortalNavigationShell(
      selectedIndex: 3,
      child: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          final horizontalPadding = sizingInfo.isDesktop ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Inline Navigation Header
                    Row(
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: const Text('Back to Attendance'),
                          onPressed: () => context.canPop() ? context.pop() : context.go('/attendance'),
                        ),
                        const Spacer(),
                        Text(
                          'Session Attendance Roster',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        BlocBuilder<AttendanceRosterCubit, AttendanceRosterState>(
                          builder: (context, state) {
                            if (state is AttendanceRosterLoaded) {
                              return TextButton.icon(
                                onPressed: () => _exportCsv(context, state.allRecords),
                                icon: const Icon(Icons.download_rounded, size: 18),
                                label: const Text('Export CSV'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryLight,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<AttendanceRosterCubit, AttendanceRosterState>(
                      builder: (context, state) {
                        if (state is AttendanceRosterLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(60),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (state is AttendanceRosterLoaded) {
                          final total = state.allRecords.length;
                          final attended = state.presentCount + state.lateCount;
                          final rate = total > 0 ? (attended / total) * 100 : 0.0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // KPI Summary Cards
                          _buildKpiSection(state, total, rate, isDark, sizingInfo),
                          const SizedBox(height: 24),

                          // Search & Filter Controls
                          _buildFilterBar(context, state, isDark),
                          const SizedBox(height: 20),

                          // Student Roster
                          if (state.filteredRecords.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text('No students match the selected filter.'),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = state.filteredRecords[index];
                                return AttendanceRecordTile(
                                  record: record,
                                  isInstructor: true,
                                  onStatusChanged: (newStatus) {
                                    context.read<AttendanceRosterCubit>().updateStatus(
                                          recordId: record.id,
                                          newStatus: newStatus,
                                        );
                                  },
                                );
                              },
                            ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
);
}

  Widget _buildKpiSection(
    AttendanceRosterLoaded state,
    int total,
    double rate,
    bool isDark,
    ResponsiveInfo sizingInfo,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric('Total Enrolled', total.toString(), AppColors.primaryLight),
          _buildMetric('Present', state.presentCount.toString(), AppColors.success),
          _buildMetric('Late', state.lateCount.toString(), AppColors.warning),
          _buildMetric('Absent', state.absentCount.toString(), AppColors.error),
          _buildMetric('Excused', state.excusedCount.toString(), AppColors.secondary),
          _buildMetric('Turnout', '${rate.toStringAsFixed(0)}%', AppColors.accentTeal),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    AttendanceRosterLoaded state,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (q) => context.read<AttendanceRosterCubit>().search(q),
                decoration: InputDecoration(
                  hintText: 'Search student name or email...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusFilterChip(label: 'All Roster', status: null, isDark: isDark),
              const SizedBox(width: 8),
              _buildStatusFilterChip(label: 'Present', status: AttendanceStatus.present, isDark: isDark, activeColor: AppColors.success),
              const SizedBox(width: 8),
              _buildStatusFilterChip(label: 'Late', status: AttendanceStatus.late, isDark: isDark, activeColor: AppColors.warning),
              const SizedBox(width: 8),
              _buildStatusFilterChip(label: 'Absent', status: AttendanceStatus.absent, isDark: isDark, activeColor: AppColors.error),
              const SizedBox(width: 8),
              _buildStatusFilterChip(label: 'Excused', status: AttendanceStatus.excused, isDark: isDark, activeColor: AppColors.secondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required AttendanceStatus? status,
    required bool isDark,
    Color? activeColor,
  }) {
    final isSelected = _selectedFilter == status;
    final color = activeColor ?? (isDark ? AppColors.primaryLight : AppColors.primary);
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = status);
        context.read<AttendanceRosterCubit>().filterByStatus(status);
      },
    );
  }
}
