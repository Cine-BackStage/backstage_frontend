import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// Loading spinner indicator for Backstage Cinema
class LoadingSpinner extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const LoadingSpinner({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  const LoadingSpinner.small({
    super.key,
    this.color,
  })  : size = AppDimensions.iconMedium,
        strokeWidth = 2.0;

  const LoadingSpinner.large({
    super.key,
    this.color,
  })  : size = AppDimensions.iconXLarge,
        strokeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? AppDimensions.iconLarge,
        height: size ?? AppDimensions.iconLarge,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? 3.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.goldenReel,
          ),
        ),
      ),
    );
  }
}
