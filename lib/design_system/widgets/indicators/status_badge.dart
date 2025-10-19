import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// Status badge styles
enum StatusBadgeType {
  scheduled,
  inProgress,
  completed,
  error,
  warning,
  info,
}

/// Status badge indicator for Backstage Cinema
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  Color get _backgroundColor {
    switch (type) {
      case StatusBadgeType.scheduled:
        return AppColors.stateScheduled;
      case StatusBadgeType.inProgress:
        return AppColors.stateInProgress;
      case StatusBadgeType.completed:
        return AppColors.stateCompleted;
      case StatusBadgeType.error:
        return AppColors.alertCritical;
      case StatusBadgeType.warning:
        return AppColors.alertWarning;
      case StatusBadgeType.info:
        return AppColors.alertInfo;
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusBadgeType.scheduled:
      case StatusBadgeType.warning:
      case StatusBadgeType.info:
        return AppColors.cinematicBlack;
      case StatusBadgeType.inProgress:
      case StatusBadgeType.completed:
      case StatusBadgeType.error:
        return AppColors.spotlightWhite;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.badgeHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.badgePadding,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppDimensions.iconSmall,
              color: _textColor,
            ),
            const SizedBox(width: AppDimensions.spacing4),
          ],
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
