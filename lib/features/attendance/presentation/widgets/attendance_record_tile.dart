import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/attendance_entity.dart';

/// Roster item card displaying a student's check-in status and override controls.
class AttendanceRecordTile extends StatelessWidget {
  final AttendanceRecordEntity record;
  final bool isInstructor;
  final ValueChanged<AttendanceStatus>? onStatusChanged;
  final VoidCallback? onAddNote;

  const AttendanceRecordTile({
    super.key,
    required this.record,
    this.isInstructor = false,
    this.onStatusChanged,
    this.onAddNote,
  });

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.absent:
        return AppColors.error;
      case AttendanceStatus.excused:
        return AppColors.secondary;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.late:
        return Icons.access_time_filled_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.excused:
        return Icons.verified_user_rounded;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return 'No check-in';
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(record.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Student Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
            backgroundImage: record.studentAvatar != null
                ? NetworkImage(record.studentAvatar!)
                : null,
            child: record.studentAvatar == null
                ? Text(
                    record.studentName.isNotEmpty
                        ? record.studentName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),

          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        record.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: record.notes!,
                        child: const Icon(
                          Icons.note_alt_outlined,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  record.studentEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTime(record.checkInTime),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (record.checkInMethod != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.lightSurfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          record.checkInMethod!.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Status Badge / Override Dropdown
          if (isInstructor && onStatusChanged != null)
            PopupMenuButton<AttendanceStatus>(
              initialValue: record.status,
              onSelected: onStatusChanged,
              tooltip: 'Change attendance status',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(record.status),
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      record.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => AttendanceStatus.values.map((s) {
                final c = _getStatusColor(s);
                return PopupMenuItem<AttendanceStatus>(
                  value: s,
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(s), size: 16, color: c),
                      const SizedBox(width: 10),
                      Text(
                        s.displayName,
                        style: TextStyle(
                          fontWeight: s == record.status
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: s == record.status ? c : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(record.status),
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    record.status.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
