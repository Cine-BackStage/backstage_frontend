import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/extensions/num_extensions.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/session.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import '../widgets/seat_map_grid.dart';
import '../widgets/ticket_purchase_dialog.dart';

class SeatSelectionPage extends StatelessWidget {
  final String sessionId;
  final bool readOnly;
  final Function(String sessionId, List<Seat> selectedSeats, Session session)? onTicketsSelected;

  const SeatSelectionPage({
    super.key,
    required this.sessionId,
    this.readOnly = false,
    this.onTicketsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(readOnly ? 'Mapa de Assentos' : 'Seleção de Assentos'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<SessionsBloc, SessionsState>(
        listener: (context, state) {
          state.whenOrNull(
            purchaseSuccess: (tickets) {
              context.pop();
              context.showSuccessSnackBar(
                'Ingressos comprados com sucesso!',
              );
            },
            // Don't show snackbar for error - the error page will display it
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () {
              // Load session details on init
              context.read<SessionsBloc>().add(
                    SessionDetailsRequested(sessionId: sessionId),
                  );
              return const Center(child: CircularProgressIndicator());
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            sessionsLoaded: (_) => const SizedBox(),
            seatSelectionLoaded: (session, seats, selectedSeats, totalPrice) {
              return Column(
                children: [
                  // Session info header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.movieTitle,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormatter.dateTime(session.startTime)} • ${session.roomName}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${session.language} • ${session.format}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seat map
                  Expanded(
                    child: SeatMapGrid(
                      seats: seats,
                      selectedSeats: selectedSeats,
                      readOnly: readOnly,
                      onSeatTap: readOnly
                          ? null
                          : (seat) {
                              final isSelected =
                                  selectedSeats.any((s) => s.id == seat.id);
                              if (isSelected) {
                                context.read<SessionsBloc>().add(
                                      SeatDeselected(seatId: seat.id),
                                    );
                              } else {
                                context.read<SessionsBloc>().add(
                                      SeatSelected(seatId: seat.id),
                                    );
                              }
                            },
                    ),
                  ),

                  // Bottom bar with selection summary (only show if not read-only)
                  if (!readOnly)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Card(
                          elevation: 0,
                          color: AppColors.background,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Total',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedSeats.isEmpty
                                            ? 'Nenhum assento'
                                            : '${selectedSeats.length} ${selectedSeats.length == 1 ? 'assento' : 'assentos'}',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                      Text(
                                        totalPrice.toCurrency(),
                                        style: AppTextStyles.h2.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: selectedSeats.isEmpty
                                      ? null
                                      : () {
                                          // If callback is provided (POS mode), use it
                                          if (onTicketsSelected != null) {
                                            onTicketsSelected!(sessionId, selectedSeats, session);
                                          } else {
                                            // Otherwise show purchase dialog (regular mode)
                                            _showPurchaseDialog(context);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text(onTicketsSelected != null ? 'Adicionar ao Carrinho' : 'Continuar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            purchasingTickets: () => const Center(
              child: CircularProgressIndicator(),
            ),
            purchaseSuccess: (_) => const SizedBox(),
            error: (failure) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: failure.isCritical
                        ? AppColors.error
                        : Colors.orange,
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SessionsBloc>().add(
                            SessionDetailsRequested(sessionId: sessionId),
                          );
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

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SessionsBloc>(),
        child: TicketPurchaseDialog(
          sessionId: sessionId,
        ),
      ),
    );
  }
}
