import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/attendance_entity.dart';
import 'portal_qr_widget.dart';

/// Projector-friendly card displaying an active lecture session's QR code & PIN.
class SessionQrDisplayCard extends StatefulWidget {
  final AttendanceSessionEntity session;
  final VoidCallback? onEndSession;
  final VoidCallback? onViewRoster;
  final bool isCompact;

  const SessionQrDisplayCard({
    super.key,
    required this.session,
    this.onEndSession,
    this.onViewRoster,
    this.isCompact = false,
  });

  @override
  State<SessionQrDisplayCard> createState() => _SessionQrDisplayCardState();
}

class _SessionQrDisplayCardState extends State<SessionQrDisplayCard> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateRemaining();
        });
      }
    });
  }

  void _updateRemaining() {
    final diff = widget.session.expiresAt.difference(DateTime.now());
    _remaining = diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.session.totalEnrolled;
    final attended = widget.session.attendedCount;
    final progress = total > 0 ? (attended / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.all(widget.isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Live status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LIVE CHECK-IN OPEN',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown timer badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (_remaining.inMinutes < 3
                          ? AppColors.error
                          : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (_remaining.inMinutes < 3
                            ? AppColors.error
                            : AppColors.primaryLight)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: _remaining.inMinutes < 3
                          ? AppColors.error
                          : AppColors.primaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _remaining == Duration.zero
                          ? 'Expired'
                          : '${_formatDuration(_remaining)} left',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _remaining.inMinutes < 3
                            ? AppColors.error
                            : AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Session Title & Meta
          Text(
            widget.session.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.session.courseCode} • ${widget.session.section} • ${widget.session.room}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Center QR Code
          Center(
            child: PortalQrWidget(
              data: widget.session.qrToken,
              size: widget.isCompact ? 160 : 210,
              remainingTime: _remaining,
              totalDuration: const Duration(minutes: 15),
              showExpiryRing: true,
            ),
          ),
          const SizedBox(height: 20),

          // 6-Digit PIN Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BACKUP 6-DIGIT PIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.session.sessionPin,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4.0,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  tooltip: 'Copy PIN to clipboard',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.session.sessionPin));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('PIN ${widget.session.sessionPin} copied to clipboard!'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Live Attendee Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Turnout: $attended of $total students',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              if (widget.onViewRoster != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onViewRoster,
                    icon: const Icon(Icons.people_alt_outlined, size: 18),
                    label: const Text('Live Roster'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              if (widget.onViewRoster != null && widget.onEndSession != null)
                const SizedBox(width: 12),
              if (widget.onEndSession != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onEndSession,
                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                    label: const Text('End Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
