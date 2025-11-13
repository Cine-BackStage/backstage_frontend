import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_screen.dart';

/// Employee profile page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      featureName: 'Profile',
      icon: Icons.person,
      description: 'View and edit your profile, clock in/out, and manage settings.',
    );
  }
}
