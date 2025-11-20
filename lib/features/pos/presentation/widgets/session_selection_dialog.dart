import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
import '../../../sessions/presentation/bloc/sessions_bloc.dart';
import '../../../sessions/presentation/bloc/sessions_event.dart';
import '../../../sessions/presentation/bloc/sessions_state.dart';
import '../../../sessions/domain/entities/session.dart';

/// Dialog to select a session for ticket sales
class SessionSelectionDialog extends StatefulWidget {
  final Function(String sessionId) onSessionSelected;

  const SessionSelectionDialog({
    super.key,
    required this.onSessionSelected,
  });

  @override
  State<SessionSelectionDialog> createState() => _SessionSelectionDialogState();
}

class _SessionSelectionDialogState extends State<SessionSelectionDialog> {
  @override
  void initState() {
    super.initState();
    // Load all upcoming sessions (don't filter by specific date to avoid timezone issues)
    print('🎬 SessionSelectionDialog: Loading all upcoming sessions');
    context.read<SessionsBloc>().add(const LoadSessionsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.movie, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Selecione uma Sessão',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<SessionsBloc, SessionsState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const Center(child: CircularProgressIndicator()),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    sessionsLoaded: (sessions) {
                      print('🎬 SessionSelectionDialog: Received ${sessions.length} sessions');

                      // Filter sessions that can sell tickets:
                      // - Not cancelled or completed
                      // - Has available seats
                      // - Start time is in the future or happening now
                      final now = DateTime.now();
                      final availableSessions = sessions.where((s) {
                        final canSell = !s.isCanceled &&
                                       !s.isCompleted &&
                                       s.availableSeats > 0 &&
                                       s.endTime.isAfter(now);

                        if (canSell) {
                          print('✅ Session ${s.movieTitle} at ${s.startTime} - Available: ${s.availableSeats} seats, Status: ${s.status}');
                        }

                        return canSell;
                      }).toList();

                      print('🎬 SessionSelectionDialog: Filtered to ${availableSessions.length} available sessions');

                      if (availableSessions.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma sessão disponível para venda de ingressos',
                                  style: AppTextStyles.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: availableSessions.length,
                        itemBuilder: (context, index) {
                          final session = availableSessions[index];
                          return _buildSessionCard(context, session);
                        },
                      );
                    },
                    seatSelectionLoaded: (_, __, ___, ____) => const SizedBox(),
                    purchasingTickets: () => const SizedBox(),
                    purchaseSuccess: (_) => const SizedBox(),
                    error: (failure) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(
                              failure.userMessage,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SessionsBloc>().add(
                                      LoadSessionsRequested(date: DateTime.now()),
                                    );
                              },
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Session session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onSessionSelected(session.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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

              // Session details
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
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.date(session.startTime),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.time(session.startTime),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.meeting_room, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          session.roomName,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.event_seat, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${session.availableSeats} disponíveis',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: session.availableSeats < 10
                                ? AppColors.alertWarning
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
