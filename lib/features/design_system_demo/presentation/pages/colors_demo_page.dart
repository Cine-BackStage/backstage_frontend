import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_dimensions.dart';

/// Colors Demo Page
class ColorsDemoPage extends StatelessWidget {
  const ColorsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colors'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: [
          Text(
            'Primary Colors',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          _ColorRow('Cinematic Black', AppColors.cinematicBlack, '#0D0D0D'),
          _ColorRow('Spotlight White', AppColors.spotlightWhite, '#F5F5F5'),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            'Accent Colors',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          _ColorRow('Golden Reel', AppColors.goldenReel, '#FFD700'),
          _ColorRow('Popcorn Yellow', AppColors.popcornYellow, '#FFD64D'),
          _ColorRow('Orange Spotlight', AppColors.orangeSpotlight, '#FF8C42'),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            'Support Colors',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          _ColorRow('Gray Curtain', AppColors.grayCurtain, '#2E2E2E'),
          _ColorRow(
              'Ticket Stub Beige', AppColors.ticketStubBeige, '#F2E6D0'),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            'Alert Colors',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          _ColorRow('Alert Red', AppColors.alertRed, '#FF4444'),
          _ColorRow('Success Green', AppColors.successGreen, '#22C55E'),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String name;
  final Color color;
  final String hex;

  const _ColorRow(this.name, this.color, this.hex);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.grayCurtain, width: 1),
            ),
          ),
          const SizedBox(width: AppDimensions.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppDimensions.spacing4),
                Text(
                  hex,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
