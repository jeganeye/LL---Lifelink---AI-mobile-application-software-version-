import 'package:flutter/material.dart';
import '../core/constants/app_text_styles.dart';
import '../models/risk_status.dart';

/// Reusable pill badge indicating AI Risk Classification.
class RiskBadge extends StatelessWidget {
  final RiskStatus status;
  final bool isCompact;

  const RiskBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.color.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: status.color.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: isCompact ? 12 : 16,
            color: status.color,
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: (isCompact ? AppTextStyles.badge : AppTextStyles.caption).copyWith(
              color: status.color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
