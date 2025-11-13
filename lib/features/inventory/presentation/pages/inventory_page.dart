import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_screen.dart';

/// Inventory management page
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      featureName: 'Inventory',
      icon: Icons.inventory_2,
      description: 'Manage stock levels, view low stock alerts, and track expiring items.',
    );
  }
}
