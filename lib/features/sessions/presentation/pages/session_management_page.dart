import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../bloc/session_management_bloc.dart';
import '../bloc/session_management_event.dart';
import '../bloc/session_management_state.dart';

class SessionManagementPage extends StatelessWidget {
  const SessionManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<SessionManagementBloc>()
        ..add(const LoadAllSessionsRequested()),
      child: const _SessionManagementView(),
    );
  }
}

class _SessionManagementView extends StatelessWidget {
  const _SessionManagementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Sessões'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<SessionManagementBloc>()
                  .add(const RefreshSessionsListRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<SessionManagementBloc, SessionManagementState>(
        listener: (context, state) {
          state.whenOrNull(
            created: (session) {
              context.showSuccessSnackBar(
                  'Sessão criada com sucesso: ${session.movieTitle}');
            },
            updated: (session) {
              context.showSuccessSnackBar('Sessão atualizada com sucesso');
            },
            deleted: (sessionId) {
              context.showSuccessSnackBar('Sessão excluída com sucesso');
            },
            error: (failure) {
              context.showErrorSnackBar(failure.userMessage);
            },
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Inicializando...')),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (sessions) {
              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma sessão cadastrada',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateSessionDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Nova Sessão'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Filter bar would go here
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<SessionManagementBloc>()
                            .add(const RefreshSessionsListRequested());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(session.status),
                                child: Icon(
                                  Icons.movie,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                session.movieTitle,
                                style: AppTextStyles.h3,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${session.roomName} • ${DateFormatter.dateTime(session.startTime)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Assentos: ${session.availableSeats}/${session.totalSeats} disponíveis',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditSessionDialog(context, session);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(
                                        context, session.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20),
                                        SizedBox(width: 8),
                                        Text('Excluir'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            creating: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Criando sessão...'),
                ],
              ),
            ),
            created: (session) => const Center(child: CircularProgressIndicator()),
            updating: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Atualizando sessão...'),
                ],
              ),
            ),
            updated: (session) => const Center(child: CircularProgressIndicator()),
            deleting: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Excluindo sessão...'),
                ],
              ),
            ),
            deleted: (sessionId) => const Center(child: CircularProgressIndicator()),
            error: (failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: failure.isCritical ? AppColors.error : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      failure.userMessage,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<SessionManagementBloc>()
                          .add(const RefreshSessionsListRequested());
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSessionDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nova Sessão'),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.green;
      case 'COMPLETED':
        return Colors.grey;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCreateSessionDialog(BuildContext context) {
    context.showErrorSnackBar('Criar sessão - Em implementação');
  }

  void _showEditSessionDialog(BuildContext context, dynamic session) {
    context.showErrorSnackBar('Editar sessão - Em implementação');
  }

  void _showDeleteConfirmation(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza que deseja excluir esta sessão? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<SessionManagementBloc>()
                  .add(DeleteSessionRequested(sessionId: sessionId));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
