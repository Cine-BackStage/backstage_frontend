import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_dimensions.dart';

/// Typography Demo Page
class TypographyDemoPage extends StatelessWidget {
  const TypographyDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typography'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: const [
          _TextStyleDemo(
            label: 'H1 - Display Large',
            text: 'The quick brown fox',
            style: AppTextStyles.h1,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'H2 - Display Medium',
            text: 'The quick brown fox',
            style: AppTextStyles.h2,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'H3 - Display Small',
            text: 'The quick brown fox',
            style: AppTextStyles.h3,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'Body Large',
            text: 'The quick brown fox jumps over the lazy dog',
            style: AppTextStyles.bodyLarge,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'Body Medium',
            text: 'The quick brown fox jumps over the lazy dog',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'Body Small',
            text: 'The quick brown fox jumps over the lazy dog',
            style: AppTextStyles.bodySmall,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'Button',
            text: 'Click Here',
            style: AppTextStyles.button,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'Caption',
            text: 'This is a caption text',
            style: AppTextStyles.caption,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'Tagline',
            text: 'This is a tagline text',
            style: AppTextStyles.tagline,
          ),
          SizedBox(height: AppDimensions.spacing24),
          _TextStyleDemo(
            label: 'Logo',
            text: 'BACKSTAGE',
            style: AppTextStyles.logo,
          ),
        ],
      ),
    );
  }
}

class _TextStyleDemo extends StatelessWidget {
  final String label;
  final String text;
  final TextStyle style;

  const _TextStyleDemo({
    required this.label,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppDimensions.spacing8),
        Text(
          text,
          style: style,
        ),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          'Size: ${style.fontSize?.toStringAsFixed(0)}px | Weight: ${style.fontWeight?.toString().split('.').last}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
