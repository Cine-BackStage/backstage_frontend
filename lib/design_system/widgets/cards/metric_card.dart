import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// Metric display card for Backstage Cinema dashboard
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? trend;
  final bool isPositiveTrend;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.trend,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: AppDimensions.iconLarge,
                  color: iconColor ?? AppColors.goldenReel,
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing8,
                      vertical: AppDimensions.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveTrend
                          ? AppColors.successGreen.withValues(alpha: 0.2)
                          : AppColors.alertRed.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositiveTrend
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: AppDimensions.iconSmall,
                          color: isPositiveTrend
                              ? AppColors.successGreen
                              : AppColors.alertRed,
                        ),
                        const SizedBox(width: AppDimensions.spacing4),
                        Text(
                          trend!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isPositiveTrend
                                ? AppColors.successGreen
                                : AppColors.alertRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing12),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.goldenReel,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing4),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
