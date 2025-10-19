import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/widgets/inputs/cine_text_field.dart';
import '../../../../design_system/widgets/buttons/primary_button.dart';
import '../../../../design_system/widgets/buttons/secondary_button.dart';
import '../../../../design_system/widgets/alerts/cine_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Forgot password page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _cpfController = TextEditingController();
  String? _cpfError;

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  void _handleRequestReset() {
    setState(() {
      _cpfError = null;
    });

    // TODO: Add proper CPF validation
    if (_cpfController.text.isEmpty) {
      setState(() {
        _cpfError = 'Por favor, digite seu CPF';
      });
      return;
    }

    context.read<AuthBloc>().add(PasswordResetRequested(_cpfController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          CineSnackbar.success(
            context,
            message: 'Instruções enviadas para seu email/telefone',
          );
          // Go back to login after a delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else if (state is AuthError) {
          CineSnackbar.error(context, message: state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Recuperar Senha'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.spacing32),

                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.spacing24),
                      decoration: BoxDecoration(
                        color: AppColors.goldenReel.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: AppColors.goldenReel,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing32),

                  // Title
                  Text(
                    'Esqueceu sua senha?',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Description
                  Text(
                    'Digite seu CPF e enviaremos instruções para redefinir sua senha.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacing40),

                  // CPF Field (using design system component)
                  CineTextField(
                    label: 'CPF',
                    hint: '000.000.000-00',
                    controller: _cpfController,
                    errorText: _cpfError,
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.person_outline),
                    // TODO: Add CPF input formatter
                  ),
                  const SizedBox(height: AppDimensions.spacing24),

                  // Submit Button (using design system component)
                  PrimaryButton(
                    label: 'Enviar Instruções',
                    onPressed: isLoading ? null : _handleRequestReset,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacing12),

                  // Back to Login Button (using design system component)
                  SecondaryButton(
                    label: 'Voltar ao Login',
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
