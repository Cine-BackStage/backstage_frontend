import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// Alert banner types
enum AlertBannerType {
  error,
  warning,
  info,
  success,
}

/// Alert banner for Backstage Cinema
class AlertBanner extends StatelessWidget {
  final String message;
  final AlertBannerType type;
  final VoidCallback? onDismiss;

  const AlertBanner({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
  });

  Color get _backgroundColor {
    switch (type) {
      case AlertBannerType.error:
        return AppColors.alertCritical;
      case AlertBannerType.warning:
        return AppColors.alertWarning;
      case AlertBannerType.info:
        return AppColors.alertInfo;
      case AlertBannerType.success:
        return AppColors.successGreen;
    }
  }

  Color get _textColor {
    switch (type) {
      case AlertBannerType.warning:
      case AlertBannerType.info:
        return AppColors.cinematicBlack;
      case AlertBannerType.error:
      case AlertBannerType.success:
        return AppColors.spotlightWhite;
    }
  }

  IconData get _icon {
    switch (type) {
      case AlertBannerType.error:
        return Icons.error;
      case AlertBannerType.warning:
        return Icons.warning;
      case AlertBannerType.info:
        return Icons.info;
      case AlertBannerType.success:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            _icon,
            color: _textColor,
            size: AppDimensions.iconMedium,
          ),
          const SizedBox(width: AppDimensions.spacing12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _textColor,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppDimensions.spacing8),
            IconButton(
              icon: Icon(
                Icons.close,
                color: _textColor,
                size: AppDimensions.iconSmall,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
