import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return state.when(
            initial: () {
              context.read<ProfileBloc>().add(const LoadProfileRequested());
              return const Center(child: CircularProgressIndicator());
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (employee, settings) => RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(const LoadProfileRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Header
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          employee.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 36, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        employee.fullName,
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.role,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Employee Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informações', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          _buildInfoRow('CPF', employee.cpf),
                          const Divider(),
                          _buildInfoRow('Matrícula', employee.employeeId),
                          const Divider(),
                          _buildInfoRow('Email', employee.email),
                          const Divider(),
                          _buildInfoRow(
                            'Status',
                            employee.isActive ? 'Ativo' : 'Inativo',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Configurações', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          _buildInfoRow('Idioma', settings.language == 'pt_BR' ? 'Português (BR)' : settings.language),
                          const Divider(),
                          _buildInfoRow('Tema', settings.theme == 'dark' ? 'Escuro' : 'Claro'),
                          const Divider(),
                          _buildInfoRow(
                            'Notificações',
                            settings.notifications ? 'Ativadas' : 'Desativadas',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            updatingPassword: () => const Center(
              child: CircularProgressIndicator(),
            ),
            passwordUpdated: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Senha alterada com sucesso!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              });
              return const Center(child: CircularProgressIndicator());
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const LoadProfileRequested());
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
