import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/attendance_entity.dart';
import '../cubit/student_check_in_cubit.dart';
import '../cubit/student_check_in_state.dart';

/// Interactive student check-in dialog featuring simulated camera scanner & PIN fallback.
class QrScannerDialog extends StatefulWidget {
  final AttendanceSessionEntity session;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String? studentAvatar;
  final VoidCallback? onCheckInSuccess;

  const QrScannerDialog({
    super.key,
    required this.session,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    this.studentAvatar,
    this.onCheckInSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required AttendanceSessionEntity session,
    required String studentId,
    required String studentName,
    required String studentEmail,
    String? studentAvatar,
    VoidCallback? onCheckInSuccess,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<StudentCheckInCubit>(),
        child: QrScannerDialog(
          session: session,
          studentId: studentId,
          studentName: studentName,
          studentEmail: studentEmail,
          studentAvatar: studentAvatar,
          onCheckInSuccess: onCheckInSuccess,
        ),
      ),
    );
  }

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _laserController;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _laserController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _triggerQrCheckIn(String token) {
    context.read<StudentCheckInCubit>().submitCheckIn(
          sessionId: widget.session.id,
          studentId: widget.studentId,
          studentName: widget.studentName,
          studentEmail: widget.studentEmail,
          studentAvatar: widget.studentAvatar,
          method: CheckInMethod.qrCode,
          pinOrToken: token,
        );
  }

  void _triggerPinCheckIn() {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;
    context.read<StudentCheckInCubit>().submitCheckIn(
          sessionId: widget.session.id,
          studentId: widget.studentId,
          studentName: widget.studentName,
          studentEmail: widget.studentEmail,
          studentAvatar: widget.studentAvatar,
          method: CheckInMethod.pinCode,
          pinOrToken: pin,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      child: Container(
        width: 440,
        constraints: const BoxConstraints(maxHeight: 620),
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<StudentCheckInCubit, StudentCheckInState>(
          listener: (context, state) {
            if (state is StudentCheckInSuccess) {
              widget.onCheckInSuccess?.call();
            }
          },
          builder: (context, state) {
            if (state is StudentCheckInSuccess) {
              return _buildSuccessView(context, state, isDark);
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.primaryLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Class Check-In',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${widget.session.courseCode} • ${widget.session.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        context.read<StudentCheckInCubit>().reset();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Switcher (Scanner vs PIN)
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('Camera Scan'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pin_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('6-Digit PIN'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Error Message if failed
                if (state is StudentCheckInFailure)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Viewfinder Scan Tab
                      _buildCameraViewfinder(context, state, isDark),
                      // Manual PIN Tab
                      _buildPinEntryTab(context, state, isDark),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraViewfinder(
    BuildContext context,
    StudentCheckInState state,
    bool isDark,
  ) {
    final isLoading = state is StudentCheckInSubmitting;

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Targeting viewfinder corners
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    children: [
                      // Corner 1: Top Left
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.primaryLight, width: 3),
                              left: BorderSide(color: AppColors.primaryLight, width: 3),
                            ),
                          ),
                        ),
                      ),
                      // Corner 2: Top Right
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.primaryLight, width: 3),
                              right: BorderSide(color: AppColors.primaryLight, width: 3),
                            ),
                          ),
                        ),
                      ),
                      // Corner 3: Bottom Left
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.primaryLight, width: 3),
                              left: BorderSide(color: AppColors.primaryLight, width: 3),
                            ),
                          ),
                        ),
                      ),
                      // Corner 4: Bottom Right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.primaryLight, width: 3),
                              right: BorderSide(color: AppColors.primaryLight, width: 3),
                            ),
                          ),
                        ),
                      ),

                      // Animated Laser Scanline
                      AnimatedBuilder(
                        animation: _laserController,
                        builder: (context, child) {
                          return Positioned(
                            top: _laserController.value * 168,
                            left: 8,
                            right: 8,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: AppColors.accentTeal,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentTeal.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Overlay instructions
                Positioned(
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Align QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                if (isLoading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Quick Instant Scan Action Button
        ElevatedButton.icon(
          onPressed: isLoading ? null : () => _triggerQrCheckIn(widget.session.qrToken),
          icon: const Icon(Icons.flash_on_rounded, size: 18),
          label: const Text('Simulate Instant QR Scan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildPinEntryTab(
    BuildContext context,
    StudentCheckInState state,
    bool isDark,
  ) {
    final isLoading = state is StudentCheckInSubmitting;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Enter the 6-digit session PIN displayed on your instructor\'s screen:',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 6-Digit PIN input
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '000000',
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                letterSpacing: 8,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryLight,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quick fill active session PIN shortcut button
          TextButton.icon(
            onPressed: () {
              _pinController.text = widget.session.sessionPin;
            },
            icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
            label: Text('Use Session PIN (${widget.session.sessionPin})'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: isLoading ? null : _triggerPinCheckIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Verify & Check In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    StudentCheckInSuccess state,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Attendance Verified!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildInfoRow('Student', widget.studentName),
              const Divider(height: 16),
              _buildInfoRow('Course', widget.session.courseCode),
              const Divider(height: 16),
              _buildInfoRow('Status', state.record.status.displayName),
              const Divider(height: 16),
              _buildInfoRow(
                'Method',
                state.record.checkInMethod?.displayName ?? 'Verified',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.read<StudentCheckInCubit>().reset();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
