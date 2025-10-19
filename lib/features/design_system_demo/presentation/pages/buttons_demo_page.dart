import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../design_system/widgets/buttons/secondary_button.dart';
import '../../../../design_system/widgets/buttons/ghost_button.dart';
import '../../../../design_system/widgets/alerts/cine_snackbar.dart';

/// Buttons Demo Page
class ButtonsDemoPage extends StatefulWidget {
  const ButtonsDemoPage({super.key});

  @override
  State<ButtonsDemoPage> createState() => _ButtonsDemoPageState();
}

class _ButtonsDemoPageState extends State<ButtonsDemoPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buttons'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: [
          Text('Primary Button', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          PrimaryButton(
            label: 'Primary Action',
            onPressed: () {
              CineSnackbar.success(context, message: 'Primary button pressed!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          PrimaryButton(
            label: 'With Icon',
            icon: Icons.add,
            onPressed: () {
              CineSnackbar.info(context, message: 'Icon button pressed!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          PrimaryButton(
            label: 'Loading State',
            isLoading: _isLoading,
            onPressed: () {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (!mounted) return;
                setState(() => _isLoading = false);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Loading complete!'),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          const PrimaryButton(
            label: 'Disabled',
            onPressed: null,
          ),
          const SizedBox(height: AppDimensions.spacing32),
          Text('Secondary Button', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          SecondaryButton(
            label: 'Secondary Action',
            onPressed: () {
              CineSnackbar.info(context, message: 'Secondary button pressed!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          SecondaryButton(
            label: 'With Icon',
            icon: Icons.edit,
            onPressed: () {
              CineSnackbar.info(context, message: 'Icon button pressed!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          const SecondaryButton(
            label: 'Disabled',
            onPressed: null,
          ),
          const SizedBox(height: AppDimensions.spacing32),
          Text('Ghost Button', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          GhostButton(
            label: 'Ghost Action',
            onPressed: () {
              CineSnackbar.info(context, message: 'Ghost button pressed!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          GhostButton(
            label: 'With Icon',
            icon: Icons.info_outline,
            onPressed: () {
              CineSnackbar.info(context, message: 'Icon button pressed!');
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          const GhostButton(
            label: 'Disabled',
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
