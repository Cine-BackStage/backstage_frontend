import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_screen.dart';

/// Sessions management page
class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      featureName: 'Sessions',
      icon: Icons.movie,
      description: 'View movie sessions, check seat availability, and sell tickets.',
    );
  }
}
