import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_screen.dart';

/// POS (Point of Sale) feature page
class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      featureName: 'Point of Sale',
      icon: Icons.shopping_cart,
      description: 'Create and manage sales transactions, add products, apply discounts, and process payments.',
    );
  }
}
