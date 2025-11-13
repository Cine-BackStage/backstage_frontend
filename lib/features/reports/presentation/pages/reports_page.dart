import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_screen.dart';

/// Reports page
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      featureName: 'Reports',
      icon: Icons.assessment,
      description: 'View sales reports, ticket analytics, and business insights.',
    );
  }
}
