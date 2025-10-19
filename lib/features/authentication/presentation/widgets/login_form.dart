import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/widgets/inputs/cine_text_field.dart';
import '../../../../design_system/widgets/inputs/cine_password_field.dart';
import '../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../design_system/widgets/buttons/ghost_button.dart';

/// Login form widget
class LoginForm extends StatefulWidget {
  final VoidCallback onForgotPassword;
  final void Function(String cpf, String password) onLogin;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onForgotPassword,
    required this.onLogin,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _cpfError;
  String? _passwordError;

  @override
  void dispose() {
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _cpfError = null;
      _passwordError = null;
    });

    // Basic validation
    // TODO: Use proper CPF validator from shared utils
    if (_cpfController.text.isEmpty) {
      setState(() {
        _cpfError = 'Por favor, digite seu CPF';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Por favor, digite sua senha';
      });
      return;
    }

    widget.onLogin(_cpfController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CPF Field (using design system component)
          CineTextField(
            label: 'CPF',
            hint: '000.000.000-00',
            controller: _cpfController,
            errorText: _cpfError,
            keyboardType: TextInputType.number,
            enabled: !widget.isLoading,
            prefixIcon: const Icon(Icons.person_outline),
            // TODO: Add CPF input formatter from shared utils
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Password Field (using design system component)
          CinePasswordField(
            label: 'Senha',
            hint: 'Digite sua senha',
            controller: _passwordController,
            errorText: _passwordError,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: AppDimensions.spacing12),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: GhostButton(
              label: 'Esqueceu sua senha?',
              onPressed: widget.isLoading ? null : widget.onForgotPassword,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),

          // Login Button (using design system component)
          PrimaryButton(
            label: 'Entrar',
            onPressed: widget.isLoading ? null : _handleLogin,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: AppDimensions.spacing16),

          // Login hints (dev only)
          // TODO: Remove in production build
          _buildLoginHints(),
        ],
      ),
    );
  }

  Widget _buildLoginHints() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing12),
      decoration: BoxDecoration(
        color: AppColors.grayCurtain.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.alertInfo.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usuários de teste:',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.alertInfo,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            'Admin: 123.456.789-00 / admin123',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Text(
            'Funcionário: 987.654.321-00 / employee123',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
