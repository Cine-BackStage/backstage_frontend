import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
import '../../../movies/presentation/bloc/movie_management_bloc.dart';
import '../../../rooms/presentation/bloc/room_management_bloc.dart';
import '../../domain/entities/session.dart';
import '../bloc/session_management_bloc.dart';
import '../bloc/session_management_event.dart';
import '../bloc/session_management_state.dart';
import 'session_form_dialog.dart';

class SessionsTab extends StatelessWidget {
  final VoidCallback onRefreshAll;

  const SessionsTab({
    super.key,
    required this.onRefreshAll,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionManagementBloc, SessionManagementState>(
      listener: (context, state) {
        state.whenOrNull(
          created: (session) {
            context.showSuccessSnackBar(
              'Sessão criada com sucesso: ${session.movieTitle}',
            );
            onRefreshAll();
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
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (sessions) => _buildSessionsList(context, sessions),
          creating: () => const Center(child: CircularProgressIndicator()),
          created: (_) => const Center(child: CircularProgressIndicator()),
          updating: () => const Center(child: CircularProgressIndicator()),
          updated: (_) => const Center(child: CircularProgressIndicator()),
          deleting: () => const Center(child: CircularProgressIndicator()),
          deleted: (_) => const Center(child: CircularProgressIndicator()),
          error: (failure) => _buildErrorView(context, failure.userMessage),
        );
      },
    );
  }

  Widget _buildSessionsList(BuildContext context, List<Session> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma sessão cadastrada',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showSessionDialog(context),
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
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sessions.length} sessões',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSessionDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nova Sessão'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionCard(context, session);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(BuildContext context, Session session) {
    final availableSeats = session.availableSeats;
    final occupancyPercentage = ((session.totalSeats - session.availableSeats) /
            session.totalSeats *
            100)
        .round();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showSessionDialog(context, session: session),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.movieTitle,
                          style: AppTextStyles.h3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.dateTime(session.startTime),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.meeting_room,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              session.roomName,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(session),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(occupancyPercentage)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$occupancyPercentage%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _getStatusColor(occupancyPercentage),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event_seat, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$availableSeats de ${session.totalSeats} assentos disponíveis',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: availableSeats < 10
                          ? AppColors.alertWarning
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (session.totalSeats - session.availableSeats) /
                      session.totalSeats,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(occupancyPercentage),
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showSessionDialog(context, session: session),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, session),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Excluir'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Session session) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (session.isScheduled) {
      statusText = 'Agendada';
      statusColor = AppColors.success;
      statusIcon = Icons.schedule;
    } else if (session.isInProgress) {
      statusText = 'Em andamento';
      statusColor = AppColors.alertWarning;
      statusIcon = Icons.play_circle;
    } else if (session.isCompleted) {
      statusText = 'Concluída';
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle;
    } else if (session.isCanceled) {
      statusText = 'Cancelada';
      statusColor = AppColors.error;
      statusIcon = Icons.cancel;
    } else {
      statusText = session.status;
      statusColor = Colors.grey;
      statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int percentage) {
    if (percentage >= 90) return AppColors.error;
    if (percentage >= 70) return AppColors.alertWarning;
    return AppColors.success;
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<SessionManagementBloc>()
                    .add(const RefreshSessionsListRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDialog(BuildContext context, {Session? session}) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SessionManagementBloc>()),
          BlocProvider.value(value: context.read<MovieManagementBloc>()),
          BlocProvider.value(value: context.read<RoomManagementBloc>()),
        ],
        child: SessionFormDialog(session: session),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a sessão "${session.movieTitle}" em ${DateFormatter.dateTime(session.startTime)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<SessionManagementBloc>()
                  .add(DeleteSessionRequested(sessionId: session.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
