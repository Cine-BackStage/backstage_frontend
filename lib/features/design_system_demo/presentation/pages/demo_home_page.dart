import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_dimensions.dart';

/// Demo Home Page - Shows all component categories
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: [
          _DemoCategoryCard(
            title: 'Colors',
            description: 'Color palette and semantic colors',
            icon: Icons.palette,
            onTap: () => Navigator.pushNamed(context, '/demo/colors'),
          ),
          _DemoCategoryCard(
            title: 'Typography',
            description: 'Text styles and font system',
            icon: Icons.text_fields,
            onTap: () => Navigator.pushNamed(context, '/demo/typography'),
          ),
          _DemoCategoryCard(
            title: 'Buttons',
            description: 'Primary, secondary, and ghost buttons',
            icon: Icons.smart_button,
            onTap: () => Navigator.pushNamed(context, '/demo/buttons'),
          ),
          _DemoCategoryCard(
            title: 'Input Fields',
            description: 'Text fields, password, and search',
            icon: Icons.input,
            onTap: () => Navigator.pushNamed(context, '/demo/inputs'),
          ),
          _DemoCategoryCard(
            title: 'Cards',
            description: 'Metric, feature, and session cards',
            icon: Icons.credit_card,
            onTap: () => Navigator.pushNamed(context, '/demo/cards'),
          ),
          _DemoCategoryCard(
            title: 'Indicators',
            description: 'Loading, progress, and status badges',
            icon: Icons.pending,
            onTap: () => Navigator.pushNamed(context, '/demo/indicators'),
          ),
          _DemoCategoryCard(
            title: 'Alerts',
            description: 'Banners and snackbars',
            icon: Icons.notifications,
            onTap: () => Navigator.pushNamed(context, '/demo/alerts'),
          ),
        ],
      ),
    );
  }
}

class _DemoCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _DemoCategoryCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.spacing16),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.spacing12),
          decoration: BoxDecoration(
            color: AppColors.goldenReel.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Icon(
            icon,
            color: AppColors.goldenReel,
            size: AppDimensions.iconLarge,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.h3,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppDimensions.spacing8),
          child: Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.goldenReel,
        ),
        onTap: onTap,
      ),
    );
  }
}
