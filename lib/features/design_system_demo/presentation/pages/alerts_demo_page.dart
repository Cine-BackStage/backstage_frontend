import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/widgets/alerts/alert_banner.dart';
import '../../../../design_system/widgets/alerts/cine_snackbar.dart';
import '../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../design_system/widgets/buttons/secondary_button.dart';

/// Alerts Demo Page
class AlertsDemoPage extends StatefulWidget {
  const AlertsDemoPage({super.key});

  @override
  State<AlertsDemoPage> createState() => _AlertsDemoPageState();
}

class _AlertsDemoPageState extends State<AlertsDemoPage> {
  bool _showErrorBanner = true;
  bool _showWarningBanner = true;
  bool _showInfoBanner = true;
  bool _showSuccessBanner = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: [
          Text('Alert Banners', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          if (_showErrorBanner)
            AlertBanner(
              message: 'This is an error message',
              type: AlertBannerType.error,
              onDismiss: () {
                setState(() => _showErrorBanner = false);
              },
            ),
          if (_showErrorBanner) const SizedBox(height: AppDimensions.spacing12),
          if (_showWarningBanner)
            AlertBanner(
              message: 'This is a warning message',
              type: AlertBannerType.warning,
              onDismiss: () {
                setState(() => _showWarningBanner = false);
              },
            ),
          if (_showWarningBanner)
            const SizedBox(height: AppDimensions.spacing12),
          if (_showInfoBanner)
            AlertBanner(
              message: 'This is an info message',
              type: AlertBannerType.info,
              onDismiss: () {
                setState(() => _showInfoBanner = false);
              },
            ),
          if (_showInfoBanner) const SizedBox(height: AppDimensions.spacing12),
          if (_showSuccessBanner)
            AlertBanner(
              message: 'This is a success message',
              type: AlertBannerType.success,
              onDismiss: () {
                setState(() => _showSuccessBanner = false);
              },
            ),
          if (_showSuccessBanner)
            const SizedBox(height: AppDimensions.spacing12),
          SecondaryButton(
            label: 'Reset All Banners',
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _showErrorBanner = true;
                _showWarningBanner = true;
                _showInfoBanner = true;
                _showSuccessBanner = true;
              });
            },
          ),
          const SizedBox(height: AppDimensions.spacing32),
          Text('Snackbars', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.spacing16),
          PrimaryButton(
            label: 'Show Error Snackbar',
            onPressed: () {
              CineSnackbar.error(
                context,
                message: 'This is an error snackbar',
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          PrimaryButton(
            label: 'Show Warning Snackbar',
            onPressed: () {
              CineSnackbar.warning(
                context,
                message: 'This is a warning snackbar',
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          PrimaryButton(
            label: 'Show Info Snackbar',
            onPressed: () {
              CineSnackbar.info(
                context,
                message: 'This is an info snackbar',
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          PrimaryButton(
            label: 'Show Success Snackbar',
            onPressed: () {
              CineSnackbar.success(
                context,
                message: 'This is a success snackbar',
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacing12),
          SecondaryButton(
            label: 'Show Snackbar with Action',
            onPressed: () {
              CineSnackbar.show(
                context,
                message: 'Do you want to undo?',
                type: SnackbarType.info,
                actionLabel: 'Undo',
                onAction: () {
                  CineSnackbar.success(
                    context,
                    message: 'Action undone!',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
