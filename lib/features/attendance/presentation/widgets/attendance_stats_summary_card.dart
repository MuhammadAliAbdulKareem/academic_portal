import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/attendance_entity.dart';

/// Visual metric card summarizing attendance rate and absence risk warnings.
class AttendanceStatsSummaryCard extends StatelessWidget {
  final StudentAttendanceSummaryEntity summary;
  final VoidCallback? onReportExcused;

  const AttendanceStatsSummaryCard({
    super.key,
    required this.summary,
    this.onReportExcused,
  });

  Color _getRateColor(double rate) {
    if (rate >= 85) return AppColors.success;
    if (rate >= 75) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rate = summary.attendanceRate;
    final rateColor = _getRateColor(rate);
    final isAtRisk = summary.isAtRisk;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAtRisk
              ? AppColors.error.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isAtRisk ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAtRisk ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.courseCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary.courseTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rateColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: rateColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${rate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: rateColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Linear Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (rate / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(rateColor),
            ),
          ),
          const SizedBox(height: 16),

          // Stat chips
          Row(
            children: [
              Expanded(
                child: _buildCountChip(
                  context,
                  label: 'Present',
                  count: summary.presentSessions,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCountChip(
                  context,
                  label: 'Late',
                  count: summary.lateSessions,
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCountChip(
                  context,
                  label: 'Absent',
                  count: summary.absentSessions,
                  color: AppColors.error,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCountChip(
                  context,
                  label: 'Excused',
                  count: summary.excusedSessions,
                  color: AppColors.secondary,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // Warning Banner if At Risk
          if (isAtRisk) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Attendance is below 75% university minimum requirement. Academic penalty may apply.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountChip(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
