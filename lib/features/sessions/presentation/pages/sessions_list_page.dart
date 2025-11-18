import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/extensions/datetime_extensions.dart';
import '../bloc/sessions_bloc.dart';
import '../bloc/sessions_event.dart';
import '../bloc/sessions_state.dart';
import '../widgets/session_card.dart';

class SessionsListPage extends StatefulWidget {
  const SessionsListPage({super.key});

  @override
  State<SessionsListPage> createState() => _SessionsListPageState();
}

class _SessionsListPageState extends State<SessionsListPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    context.read<SessionsBloc>().add(LoadSessionsRequested(
          date: _selectedDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessões'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: BlocBuilder<SessionsBloc, SessionsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(
                    child: Text('Selecione uma data para ver as sessões'),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  sessionsLoaded: (sessions) {
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
                              'Nenhuma sessão encontrada',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<SessionsBloc>().add(
                              const RefreshSessionsRequested(),
                            );
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          return SessionCard(
                            session: sessions[index],
                            onTap: () {
                              // Navigate to seat selection with readOnly=true
                              context.pushNamed(
                                '/sessions/${sessions[index].id}/seats',
                                arguments: {'readOnly': true},
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  seatSelectionLoaded: (_, __, ___, ____) => const SizedBox(),
                  purchasingTickets: () => const SizedBox(),
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
                        if (failure.technicalMessage != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              failure.technicalMessage!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadSessions,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtractDays(1);
              });
              _loadSessions();
            },
          ),
          Expanded(
            child: Center(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _loadSessions();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    _selectedDate.isToday
                        ? 'Hoje'
                        : _selectedDate.isTomorrow
                            ? 'Amanhã'
                            : _formatDate(_selectedDate),
                    style: AppTextStyles.h3,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.addDays(1);
              });
              _loadSessions();
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];

    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }
}
