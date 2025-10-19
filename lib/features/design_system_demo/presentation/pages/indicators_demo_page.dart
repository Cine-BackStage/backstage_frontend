import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/widgets/indicators/loading_spinner.dart';
import '../../../../design_system/widgets/indicators/progress_bar.dart';
import '../../../../design_system/widgets/indicators/status_badge.dart';

/// Indicators Demo Page
class IndicatorsDemoPage extends StatelessWidget {
  const IndicatorsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicators'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: const [
          Text('Loading Spinners', style: AppTextStyles.h3),
          SizedBox(height: AppDimensions.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  LoadingSpinner.small(),
                  SizedBox(height: AppDimensions.spacing8),
                  Text('Small', style: AppTextStyles.bodySmall),
                ],
              ),
              Column(
                children: [
                  LoadingSpinner(),
                  SizedBox(height: AppDimensions.spacing8),
                  Text('Medium', style: AppTextStyles.bodySmall),
                ],
              ),
              Column(
                children: [
                  LoadingSpinner.large(),
                  SizedBox(height: AppDimensions.spacing8),
                  Text('Large', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing32),
          Text('Progress Bars', style: AppTextStyles.h3),
          SizedBox(height: AppDimensions.spacing16),
          CineProgressBar(
            value: 0.3,
            label: 'Low Progress',
          ),
          SizedBox(height: AppDimensions.spacing16),
          CineProgressBar(
            value: 0.65,
            label: 'Medium Progress',
          ),
          SizedBox(height: AppDimensions.spacing16),
          CineProgressBar(
            value: 0.95,
            label: 'High Progress',
          ),
          SizedBox(height: AppDimensions.spacing16),
          CineProgressBar(
            value: 0.5,
            label: 'With Custom Color',
            color: AppColors.orangeSpotlight,
          ),
          SizedBox(height: AppDimensions.spacing32),
          Text('Status Badges', style: AppTextStyles.h3),
          SizedBox(height: AppDimensions.spacing16),
          Wrap(
            spacing: AppDimensions.spacing8,
            runSpacing: AppDimensions.spacing8,
            children: [
              StatusBadge(
                label: 'Scheduled',
                type: StatusBadgeType.scheduled,
                icon: Icons.schedule,
              ),
              StatusBadge(
                label: 'In Progress',
                type: StatusBadgeType.inProgress,
                icon: Icons.play_circle,
              ),
              StatusBadge(
                label: 'Completed',
                type: StatusBadgeType.completed,
                icon: Icons.check_circle,
              ),
              StatusBadge(
                label: 'Error',
                type: StatusBadgeType.error,
                icon: Icons.error,
              ),
              StatusBadge(
                label: 'Warning',
                type: StatusBadgeType.warning,
                icon: Icons.warning,
              ),
              StatusBadge(
                label: 'Info',
                type: StatusBadgeType.info,
                icon: Icons.info,
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing16),
          Text('Without Icons', style: AppTextStyles.bodyMedium),
          SizedBox(height: AppDimensions.spacing12),
          Wrap(
            spacing: AppDimensions.spacing8,
            runSpacing: AppDimensions.spacing8,
            children: [
              StatusBadge(
                label: 'Scheduled',
                type: StatusBadgeType.scheduled,
              ),
              StatusBadge(
                label: 'In Progress',
                type: StatusBadgeType.inProgress,
              ),
              StatusBadge(
                label: 'Completed',
                type: StatusBadgeType.completed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
