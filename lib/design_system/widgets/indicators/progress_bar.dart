import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

/// Progress bar indicator for Backstage Cinema
class CineProgressBar extends StatelessWidget {
  final double value;
  final String? label;
  final Color? color;
  final Color? backgroundColor;
  final double? height;

  const CineProgressBar({
    super.key,
    required this.value,
    this.label,
    this.color,
    this.backgroundColor,
    this.height,
  }) : assert(value >= 0.0 && value <= 1.0, 'Value must be between 0 and 1');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: AppTextStyles.bodySmall,
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldenReel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          child: SizedBox(
            height: height ?? AppDimensions.progressBarHeight,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: backgroundColor ?? AppColors.grayCurtain,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.goldenReel,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
