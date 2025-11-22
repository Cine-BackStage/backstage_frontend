import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/movie_usecases.dart';
import '../bloc/movie_management_bloc.dart';
import '../bloc/movie_management_event.dart';

class MovieFormDialog extends StatefulWidget {
  final Movie? movie; // null = create mode, not null = edit mode

  const MovieFormDialog({super.key, this.movie});

  @override
  State<MovieFormDialog> createState() => _MovieFormDialogState();
}

class _MovieFormDialogState extends State<MovieFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _genreController;
  String? _selectedRating;
  DateTime? _releaseDate;

  bool get isEditMode => widget.movie != null;

  @override
  void initState() {
    super.initState();
    final movie = widget.movie;
    _titleController = TextEditingController(text: movie?.title ?? '');
    _durationController = TextEditingController(
      text: movie?.durationMin.toString() ?? '',
    );
    _genreController = TextEditingController(text: movie?.genre ?? '');
    _selectedRating = movie?.rating;
    _releaseDate = movie?.releaseDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final duration = int.tryParse(_durationController.text) ?? 0;

    if (isEditMode) {
      // Update existing movie
      context.read<MovieManagementBloc>().add(
        UpdateMovieRequested(
          params: UpdateMovieParams(
            movieId: widget.movie!.id,
            title: _titleController.text.trim(),
            durationMin: duration,
            genre: _genreController.text.trim(),
            rating: _selectedRating ?? '',
            releaseDate: _releaseDate,
          ),
        ),
      );
    } else {
      // Create new movie
      context.read<MovieManagementBloc>().add(
        CreateMovieRequested(
          params: CreateMovieParams(
            title: _titleController.text.trim(),
            durationMin: duration,
            genre: _genreController.text.trim(),
            rating: _selectedRating ?? '',
            releaseDate: _releaseDate,
          ),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  Future<void> _selectReleaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _releaseDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode ? 'Editar Filme' : 'Novo Filme',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
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
                      // Title (required)
                      TextFormField(
                        key: const Key('movieTitleField'),
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título *',
                          hintText: 'Ex: Avatar',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Título é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Duration and Genre
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: const Key('movieDurationField'),
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duração (min) *',
                                hintText: 'Ex: 120',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Duração é obrigatória';
                                }
                                final duration = int.tryParse(value);
                                if (duration == null || duration <= 0) {
                                  return 'Duração inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              key: const Key('movieGenreField'),
                              controller: _genreController,
                              decoration: const InputDecoration(
                                labelText: 'Gênero *',
                                hintText: 'Ex: Ação',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Gênero é obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rating Dropdown
                      DropdownButtonFormField<String>(
                        key: const Key('movieRatingDropdown'),
                        value: _selectedRating,
                        decoration: const InputDecoration(
                          labelText: 'Classificação *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'L',
                            child: Text('L - Livre'),
                          ),
                          DropdownMenuItem(
                            value: '10',
                            child: Text('10 - 10 anos'),
                          ),
                          DropdownMenuItem(
                            value: '12',
                            child: Text('12 - 12 anos'),
                          ),
                          DropdownMenuItem(
                            value: '14',
                            child: Text('14 - 14 anos'),
                          ),
                          DropdownMenuItem(
                            value: '16',
                            child: Text('16 - 16 anos'),
                          ),
                          DropdownMenuItem(
                            value: '18',
                            child: Text('18 - 18 anos'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRating = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Classificação é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Release Date
                      InkWell(
                        onTap: _selectReleaseDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data de Lançamento',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _releaseDate != null
                                ? '${_releaseDate!.day.toString().padLeft(2, '0')}/${_releaseDate!.month.toString().padLeft(2, '0')}/${_releaseDate!.year}'
                                : 'Selecionar data',
                            style: _releaseDate != null
                                ? null
                                : TextStyle(color: Colors.grey[600]),
                          ),
                        ),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
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
                    key: const Key('saveMovieButton'),
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
        ),
      ),
    );
  }
}
