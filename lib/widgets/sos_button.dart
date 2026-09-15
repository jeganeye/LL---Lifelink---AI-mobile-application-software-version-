import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Large pulsating SOS button designed for rapid emergency access.
class SosButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final bool isTriggered;
  final int? countdownSeconds;

  const SosButton({
    super.key,
    required this.onPressed,
    this.size = 140,
    this.isTriggered = false,
    this.countdownSeconds,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = widget.isTriggered ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.emergencyGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.statusEmergency.withOpacity(
                    widget.isTriggered ? 0.6 : 0.35,
                  ),
                  blurRadius: widget.isTriggered ? 30 : 18,
                  spreadRadius: widget.isTriggered ? 6 : 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emergency,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isTriggered && widget.countdownSeconds != null
                        ? '${widget.countdownSeconds}s'
                        : 'SOS',
                    style: AppTextStyles.headline.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: widget.isTriggered ? 26 : 24,
                    ),
                  ),
                  Text(
                    widget.isTriggered ? 'CANCEL' : 'EMERGENCY',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
