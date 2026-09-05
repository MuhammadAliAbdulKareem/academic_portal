import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A custom-painted, high-contrast QR visual widget for session verification.
class PortalQrWidget extends StatelessWidget {
  final String data;
  final double size;
  final Duration? remainingTime;
  final Duration totalDuration;
  final bool showExpiryRing;
  final VoidCallback? onTap;

  const PortalQrWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.remainingTime,
    this.totalDuration = const Duration(minutes: 15),
    this.showExpiryRing = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : AppColors.primaryDark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final progress = (remainingTime != null && totalDuration.inSeconds > 0)
        ? (remainingTime!.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
        : 1.0;

    final qrWidget = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.blueGrey).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size - 24, size - 24),
            painter: _QrMatrixPainter(
              data: data,
              foregroundColor: fgColor,
              backgroundColor: bgColor,
            ),
          ),
          // Central emblem badge
          Container(
            width: size * 0.22,
            height: size * 0.22,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryLight,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.school_rounded,
              size: size * 0.12,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );

    if (!showExpiryRing || remainingTime == null) {
      return GestureDetector(onTap: onTap, child: qrWidget);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size + 28,
            height: size + 28,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0.2
                    ? AppColors.error
                    : (progress < 0.4 ? AppColors.warning : AppColors.accentTeal),
              ),
            ),
          ),
          qrWidget,
        ],
      ),
    );
  }
}

class _QrMatrixPainter extends CustomPainter {
  final String data;
  final Color foregroundColor;
  final Color backgroundColor;

  _QrMatrixPainter({
    required this.data,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const matrixDimension = 21;
    final cellSize = size.width / matrixDimension;
    final paint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;

    // Seed pseudo-random matrix using hash of data string
    final random = Random(data.hashCode);

    // Draw finder patterns in 3 corners (7x7 outer, 3x3 inner)
    _drawFinderPattern(canvas, 0, 0, cellSize, paint);
    _drawFinderPattern(canvas, matrixDimension - 7, 0, cellSize, paint);
    _drawFinderPattern(canvas, 0, matrixDimension - 7, cellSize, paint);

    // Center zone cutout bounds
    const centerStart = 8;
    const centerEnd = 13;

    for (int r = 0; r < matrixDimension; r++) {
      for (int c = 0; c < matrixDimension; c++) {
        // Skip corner finder zones
        final inTopLeft = r < 7 && c < 7;
        final inTopRight = r < 7 && c >= matrixDimension - 7;
        final inBottomLeft = r >= matrixDimension - 7 && c < 7;

        // Skip center emblem zone
        final inCenter =
            r >= centerStart && r <= centerEnd && c >= centerStart && c <= centerEnd;

        if (inTopLeft || inTopRight || inBottomLeft || inCenter) {
          continue;
        }

        // Timing patterns
        if (r == 6 || c == 6) {
          if ((r + c) % 2 == 0) {
            _drawCell(canvas, c, r, cellSize, paint);
          }
          continue;
        }

        // Deterministic pseudo-random content modules
        if (random.nextDouble() > 0.48) {
          _drawCell(canvas, c, r, cellSize, paint);
        }
      }
    }
  }

  void _drawCell(Canvas canvas, int c, int r, double cellSize, Paint paint) {
    final rect = Rect.fromLTWH(
      c * cellSize + 0.6,
      r * cellSize + 0.6,
      cellSize - 1.2,
      cellSize - 1.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.2)),
      paint,
    );
  }

  void _drawFinderPattern(
    Canvas canvas,
    int startX,
    int startY,
    double cellSize,
    Paint paint,
  ) {
    final outerRect = Rect.fromLTWH(
      startX * cellSize,
      startY * cellSize,
      7 * cellSize,
      7 * cellSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(outerRect, Radius.circular(cellSize * 0.8)),
      paint,
    );

    // Inner white cutout
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final innerCutout = Rect.fromLTWH(
      (startX + 1) * cellSize,
      (startY + 1) * cellSize,
      5 * cellSize,
      5 * cellSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerCutout, Radius.circular(cellSize * 0.5)),
      bgPaint,
    );

    // Inner filled 3x3 square
    final centerRect = Rect.fromLTWH(
      (startX + 2) * cellSize,
      (startY + 2) * cellSize,
      3 * cellSize,
      3 * cellSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, Radius.circular(cellSize * 0.4)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
