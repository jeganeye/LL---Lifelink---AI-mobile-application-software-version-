import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Top banner displayed across pages indicating Prototype Demo Mode for SIH 2026.
class DemoBanner extends StatelessWidget {
  final String message;
  final bool isDismissible;

  const DemoBanner({
    super.key,
    this.message = 'SIH 2026 PROTOTYPE • SIMULATED DEMO DATA • NOT FOR CLINICAL USE',
    this.isDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.25),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryLight.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.science_outlined,
            size: 14,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
