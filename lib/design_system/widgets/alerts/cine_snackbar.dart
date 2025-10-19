import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

/// Snackbar types
enum SnackbarType {
  error,
  warning,
  info,
  success,
}

/// Snackbar utility for Backstage Cinema
class CineSnackbar {
  CineSnackbar._();

  static Color _getBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return AppColors.alertCritical;
      case SnackbarType.warning:
        return AppColors.alertWarning;
      case SnackbarType.info:
        return AppColors.alertInfo;
      case SnackbarType.success:
        return AppColors.successGreen;
    }
  }

  static Color _getTextColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.warning:
      case SnackbarType.info:
        return AppColors.cinematicBlack;
      case SnackbarType.error:
      case SnackbarType.success:
        return AppColors.spotlightWhite;
    }
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
      case SnackbarType.success:
        return Icons.check_circle;
    }
  }

  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final backgroundColor = _getBackgroundColor(type);
    final textColor = _getTextColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: textColor,
              size: AppDimensions.iconMedium,
            ),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(context, message: message, type: SnackbarType.error, duration: duration);
  }

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, type: SnackbarType.success, duration: duration);
  }

  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(context, message: message, type: SnackbarType.warning, duration: duration);
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, type: SnackbarType.info, duration: duration);
  }
}
