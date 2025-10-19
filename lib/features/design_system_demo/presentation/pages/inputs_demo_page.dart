import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/widgets/inputs/cine_text_field.dart';
import '../../../../design_system/widgets/inputs/cine_password_field.dart';
import '../../../../design_system/widgets/inputs/search_field.dart';

/// Inputs Demo Page
class InputsDemoPage extends StatelessWidget {
  const InputsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Fields'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        children: const [
          Text('Text Field', style: AppTextStyles.h3),
          SizedBox(height: AppDimensions.spacing16),
          CineTextField(
            label: 'Name',
            hint: 'Enter your name',
            prefixIcon: Icon(Icons.person),
          ),
          SizedBox(height: AppDimensions.spacing16),
          CineTextField(
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: AppDimensions.spacing16),
          CineTextField(
            label: 'Phone',
            hint: 'Enter your phone',
            prefixIcon: Icon(Icons.phone),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: AppDimensions.spacing16),
          CineTextField(
            label: 'With Error',
            hint: 'This field has an error',
            errorText: 'This field is required',
            prefixIcon: Icon(Icons.error),
          ),
          SizedBox(height: AppDimensions.spacing16),
          CineTextField(
            label: 'Disabled',
            hint: 'This field is disabled',
            enabled: false,
          ),
          SizedBox(height: AppDimensions.spacing32),
          Text('Password Field', style: AppTextStyles.h3),
          SizedBox(height: AppDimensions.spacing16),
          CinePasswordField(
            label: 'Password',
            hint: 'Enter your password',
          ),
          SizedBox(height: AppDimensions.spacing16),
          CinePasswordField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
          ),
          SizedBox(height: AppDimensions.spacing16),
          CinePasswordField(
            label: 'With Error',
            hint: 'Password mismatch',
            errorText: 'Passwords do not match',
          ),
          SizedBox(height: AppDimensions.spacing32),
          Text('Search Field', style: AppTextStyles.h3),
          SizedBox(height: AppDimensions.spacing16),
          SearchField(
            hint: 'Search...',
          ),
          SizedBox(height: AppDimensions.spacing16),
          SearchField(
            hint: 'Search movies...',
          ),
          SizedBox(height: AppDimensions.spacing16),
          SearchField(
            hint: 'Disabled search',
            enabled: false,
          ),
        ],
      ),
    );
  }
}
