import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/widgets/cards/metric_card.dart';
import '../../../../design_system/widgets/cards/feature_card.dart';
import '../../../../design_system/widgets/cards/session_card.dart';
import '../../../../design_system/widgets/indicators/status_badge.dart';
import '../../../../design_system/widgets/alerts/cine_snackbar.dart';

/// Cards Demo Page
class CardsDemoPage extends StatelessWidget {
  const CardsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: [
          Text('Metric Cards', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          const MetricCard(
            label: 'Total Sales',
            value: 'R\$ 12.450,00',
            icon: Icons.attach_money,
            iconColor: AppColors.successGreen,
            trend: '+12%',
            isPositiveTrend: true,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          const MetricCard(
            label: 'Tickets Sold',
            value: '1,234',
            icon: Icons.confirmation_number,
            iconColor: AppColors.goldenReel,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          const MetricCard(
            label: 'Occupancy Rate',
            value: '65%',
            icon: Icons.people,
            iconColor: AppColors.orangeSpotlight,
            trend: '-8%',
            isPositiveTrend: false,
          ),
          const SizedBox(height: AppDimensions.spacing32),
          Text('Feature Cards', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          const FeatureCard(
            title: 'Point of Sale',
            description: 'Quick and intuitive ticket and product sales',
            icon: Icons.point_of_sale,
            iconColor: AppColors.orangeSpotlight,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          const FeatureCard(
            title: 'Session Management',
            description: 'Complete control of sessions and cinema rooms',
            icon: Icons.theaters,
            iconColor: AppColors.goldenReel,
          ),
          const SizedBox(height: AppDimensions.spacing32),
          Text('Session Cards', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          SessionCard(
            movieTitle: 'Avatar: The Way of Water',
            roomName: 'Sala 1',
            time: '19:30',
            status: StatusBadgeType.inProgress,
            statusLabel: 'Em Andamento',
            occupancy: 145,
            capacity: 200,
            onTap: () {
              CineSnackbar.info(context, message: 'Session card tapped!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          SessionCard(
            movieTitle: 'Oppenheimer',
            roomName: 'Sala 2',
            time: '20:00',
            status: StatusBadgeType.scheduled,
            statusLabel: 'Agendada',
            occupancy: 80,
            capacity: 150,
            onTap: () {
              CineSnackbar.info(context, message: 'Session card tapped!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          SessionCard(
            movieTitle: 'Barbie',
            roomName: 'Sala 3',
            time: '18:00',
            status: StatusBadgeType.completed,
            statusLabel: 'Finalizada',
            occupancy: 120,
            capacity: 120,
            onTap: () {
              CineSnackbar.info(context, message: 'Session card tapped!');
            },
          ),
        ],
      ),
    );
  }
}
