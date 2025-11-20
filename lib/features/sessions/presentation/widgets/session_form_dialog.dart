import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../movies/presentation/bloc/movie_management_bloc.dart';
import '../../../movies/presentation/bloc/movie_management_state.dart';
import '../../../rooms/presentation/bloc/room_management_bloc.dart';
import '../../../rooms/presentation/bloc/room_management_state.dart';
import '../../domain/entities/session.dart';
import '../bloc/session_management_bloc.dart';
import '../bloc/session_management_event.dart';

class SessionFormDialog extends StatefulWidget {
  final Session? session; // null = create mode, not null = edit mode

  const SessionFormDialog({
    super.key,
    this.session,
  });

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMovieId;
  String? _selectedRoomId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool get isEditMode => widget.session != null;

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    _selectedMovieId = session?.movieId;
    _selectedRoomId = session?.roomId;
    if (session != null) {
      _selectedDate = session.startTime;
      _selectedTime = TimeOfDay.fromDateTime(session.startTime);
    }
  }

  String _calculateStatus() {
    final sessionDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (sessionDateTime.isBefore(now)) {
      return 'COMPLETED';
    } else if (sessionDate.isAtSameMomentAs(today)) {
      // Session is scheduled for today but hasn't started yet
      return 'IN_PROGRESS';
    } else {
      return 'SCHEDULED';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMovieId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um filme')),
      );
      return;
    }

    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma sala')),
      );
      return;
    }

    final startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Auto-calculate status based on date/time
    final calculatedStatus = _calculateStatus();

    if (isEditMode) {
      // Update existing session
      context.read<SessionManagementBloc>().add(
            UpdateSessionRequested(
              sessionId: widget.session!.id,
              movieId: _selectedMovieId,
              roomId: _selectedRoomId,
              startTime: startTime,
              status: calculatedStatus,
            ),
          );
    } else {
      // Create new session (backend will calculate base price from room type)
      context.read<SessionManagementBloc>().add(
            CreateSessionRequested(
              movieId: _selectedMovieId!,
              roomId: _selectedRoomId!,
              startTime: startTime,
            ),
          );
    }

    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 550,
        constraints: const BoxConstraints(maxHeight: 700),
        child: BlocBuilder<MovieManagementBloc, MovieManagementState>(
          builder: (context, movieState) {
            return BlocBuilder<RoomManagementBloc, RoomManagementState>(
              builder: (context, roomState) {
                // Check if data is still loading
                final moviesLoaded = movieState is MovieManagementLoaded;
                final roomsLoaded = roomState is RoomManagementLoaded;

                if (!moviesLoaded || !roomsLoaded) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              isEditMode ? 'Editar Sessão' : 'Nova Sessão',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      // Loading indicator
                      const Padding(
                        padding: EdgeInsets.all(100),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isEditMode ? Icons.edit : Icons.add,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditMode ? 'Editar Sessão' : 'Nova Sessão',
                            style:
                                AppTextStyles.h2.copyWith(color: Colors.white),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Form
                    Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Selector
                      Text(
                        'Filme *',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<MovieManagementBloc, MovieManagementState>(
                        builder: (context, state) {
                          if (state is MovieManagementLoaded) {
                            final activeMovies = state.movies
                                .where((movie) => movie.isActive)
                                .toList();
                            return DropdownButtonFormField<String>(
                              value: _selectedMovieId,
                              decoration: const InputDecoration(
                                hintText: 'Selecione um filme',
                                border: OutlineInputBorder(),
                              ),
                              items: activeMovies.map((movie) {
                                return DropdownMenuItem(
                                  value: movie.id,
                                  child: Text(
                                    '${movie.title} (${movie.durationMin}min)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMovieId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Selecione um filme';
                                }
                                return null;
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Room Selector
                      Text(
                        'Sala *',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<RoomManagementBloc, RoomManagementState>(
                        builder: (context, state) {
                          if (state is RoomManagementLoaded) {
                            final activeRooms = state.rooms
                                .where((room) => room.isActive)
                                .toList();
                            return DropdownButtonFormField<String>(
                              value: _selectedRoomId,
                              decoration: const InputDecoration(
                                hintText: 'Selecione uma sala',
                                border: OutlineInputBorder(),
                              ),
                              items: activeRooms.map((room) {
                                return DropdownMenuItem(
                                  value: room.id,
                                  child: Text(
                                    '${room.name} - ${room.roomType.label} (${room.capacity} assentos)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoomId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Selecione uma sala';
                                }
                                return null;
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data *',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectDate,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(_selectedDate),
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hora *',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectTime,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.access_time),
                                    ),
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(isEditMode ? 'Salvar' : 'Criar'),
                  ),
                ],
              ),
            ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

}
