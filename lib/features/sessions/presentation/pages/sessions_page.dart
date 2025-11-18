import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
import '../../domain/entities/session.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import 'seat_selection_page.dart';

/// Sessions management page - displays all movie sessions
class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<SessionsBloc>()
        ..add(const LoadSessionsRequested()),
      child: const _SessionsView(),
    );
  }
}

class _SessionsView extends StatefulWidget {
  const _SessionsView();

  @override
  State<_SessionsView> createState() => _SessionsViewState();
}

class _SessionsViewState extends State<_SessionsView> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessões'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Filtrar por data',
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
                context.read<SessionsBloc>().add(const LoadSessionsRequested());
              },
              tooltip: 'Limpar filtro',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SessionsBloc>().add(
                    LoadSessionsRequested(date: _selectedDate),
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.alertInfo.withValues(alpha: 0.2),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Filtrando por: ${DateFormatter.date(_selectedDate!)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<SessionsBloc, SessionsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(child: CircularProgressIndicator()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  sessionsLoaded: (sessions) => _buildSessionsList(context, sessions),
                  seatSelectionLoaded: (_, __, ___, ____) => const SizedBox(),
                  purchasingTickets: () => const Center(child: CircularProgressIndicator()),
                  purchaseSuccess: (_) => const SizedBox(),
                  error: (failure) => _buildErrorView(context, failure.userMessage),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, List<Session> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedDate != null
                  ? 'Nenhuma sessão encontrada para esta data'
                  : 'Nenhuma sessão disponível',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600]),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                  context.read<SessionsBloc>().add(const LoadSessionsRequested());
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar filtro'),
              ),
            ],
          ],
        ),
      );
    }

    // Group sessions by date
    final sessionsByDate = <DateTime, List<Session>>{};
    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      sessionsByDate.putIfAbsent(date, () => []).add(session);
    }

    final sortedDates = sessionsByDate.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        final dateSessions = sessionsByDate[date]!;
        dateSessions.sort((a, b) => a.startTime.compareTo(b.startTime));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                DateFormatter.date(date),
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
            ...dateSessions.map((session) => _buildSessionCard(context, session)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, Session session) {
    final availableSeats = session.availableSeats;
    final occupancyPercentage = ((session.totalSeats - session.availableSeats) / session.totalSeats * 100).round();

    // Only allow navigation if session can sell tickets (SCHEDULED status)
    final canTap = session.canSellTickets;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: canTap ? () => _navigateToSeatSelection(context, session) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster placeholder
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.movie, size: 32),
                  ),
                  const SizedBox(width: 16),
                  // Session info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.movieTitle,
                          style: AppTextStyles.h3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.time(session.startTime),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.meeting_room, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              session.roomName,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.event_seat, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '$availableSeats assentos disponíveis',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: availableSeats < 10 ? AppColors.alertWarning : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Session status badge
                        _buildStatusBadge(session),
                      ],
                    ),
                  ),
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(occupancyPercentage).withValues(alpha: 0.2),
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
              const SizedBox(height: 12),
              // Occupancy bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (session.totalSeats - session.availableSeats) / session.totalSeats,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(occupancyPercentage),
                  ),
                  minHeight: 8,
                ),
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
          Icon(statusIcon, size: 14, color: statusColor),
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
                context.read<SessionsBloc>().add(
                      LoadSessionsRequested(date: _selectedDate),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      if (context.mounted) {
        context.read<SessionsBloc>().add(LoadSessionsRequested(date: picked));
      }
    }
  }

  void _navigateToSeatSelection(BuildContext context, Session session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<SessionsBloc>(),
          child: SeatSelectionPage(
            sessionId: session.id,
            readOnly: true, // View-only mode from sessions list
          ),
        ),
      ),
    );
  }
}
