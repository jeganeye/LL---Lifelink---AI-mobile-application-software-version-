import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Animated live pulse / ECG waveform painter.
class LivePulseChart extends StatefulWidget {
  final Color lineColor;
  final double height;
  final bool isAnimated;

  const LivePulseChart({
    super.key,
    this.lineColor = AppColors.heartRate,
    this.height = 60,
    this.isAnimated = true,
  });

  @override
  State<LivePulseChart> createState() => _LivePulseChartState();
}

class _LivePulseChartState extends State<LivePulseChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PulseWavePainter(
              progress: _controller.value,
              lineColor: widget.lineColor,
            ),
          );
        },
      ),
    );
  }
}

class _PulseWavePainter extends CustomPainter {
  final double progress;
  final Color lineColor;

  _PulseWavePainter({required this.progress, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = lineColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final midY = size.height * 0.55;

    // ECG wave points
    const pointCount = 100;
    for (int i = 0; i <= pointCount; i++) {
      final x = (i / pointCount) * width;
      final normalizedX = (i / pointCount - progress) % 1.0;
      final t = normalizedX < 0 ? normalizedX + 1.0 : normalizedX;

      double y = midY;

      // Realistic P-Q-R-S-T cardiac waveform profile
      if (t >= 0.35 && t < 0.40) {
        // P-wave
        y -= 6 * sin((t - 0.35) / 0.05 * pi);
      } else if (t >= 0.43 && t < 0.46) {
        // Q-wave
        y += 5 * sin((t - 0.43) / 0.03 * pi);
      } else if (t >= 0.46 && t < 0.52) {
        // R-peak (steep high spike)
        y -= (size.height * 0.42) * sin((t - 0.46) / 0.06 * pi);
      } else if (t >= 0.52 && t < 0.55) {
        // S-wave
        y += 8 * sin((t - 0.52) / 0.03 * pi);
      } else if (t >= 0.60 && t < 0.70) {
        // T-wave
        y -= 9 * sin((t - 0.60) / 0.10 * pi);
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.lineColor != lineColor;
  }
}
