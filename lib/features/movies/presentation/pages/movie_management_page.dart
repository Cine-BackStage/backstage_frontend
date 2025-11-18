import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/movie_usecases.dart';
import '../bloc/movie_management_bloc.dart';
import '../bloc/movie_management_event.dart';
import '../bloc/movie_management_state.dart';

class MovieManagementPage extends StatelessWidget {
  const MovieManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<MovieManagementBloc>()
        ..add(const LoadMoviesRequested()),
      child: const _MovieManagementView(),
    );
  }
}

class _MovieManagementView extends StatefulWidget {
  const _MovieManagementView();

  @override
  State<_MovieManagementView> createState() => _MovieManagementViewState();
}

class _MovieManagementViewState extends State<_MovieManagementView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Filmes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MovieManagementBloc>().add(const RefreshMoviesRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<MovieManagementBloc, MovieManagementState>(
        listener: (context, state) {
          state.whenOrNull(
            saved: (movie) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filme salvo com sucesso'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<MovieManagementBloc>().add(const LoadMoviesRequested());
            },
            deleted: (movieId) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filme excluído com sucesso'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<MovieManagementBloc>().add(const LoadMoviesRequested());
            },
            error: (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.userMessage),
                  backgroundColor: failure.isCritical ? AppColors.error : AppColors.alertWarning,
                ),
              );
            },
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: state.when(
                  initial: () => const Center(child: Text('Carregando filmes...')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (movies) => _buildMoviesList(context, movies),
                  saving: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Salvando filme...'),
                      ],
                    ),
                  ),
                  saved: (movie) => const Center(child: CircularProgressIndicator()),
                  deleting: () => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Excluindo filme...'),
                      ],
                    ),
                  ),
                  deleted: (movieId) => const Center(child: CircularProgressIndicator()),
                  error: (failure) => _buildErrorView(context, failure.userMessage),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMovieDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Filme'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar filmes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<MovieManagementBloc>().add(const LoadMoviesRequested());
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (query) {
          if (query.isEmpty) {
            context.read<MovieManagementBloc>().add(const LoadMoviesRequested());
          } else {
            context.read<MovieManagementBloc>().add(SearchMoviesRequested(query: query));
          }
        },
      ),
    );
  }

  Widget _buildMoviesList(BuildContext context, List<Movie> movies) {
    if (movies.isEmpty) {
      return const Center(
        child: Text('Nenhum filme encontrado'),
      );
    }

    return ListView.builder(
      itemCount: movies.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _buildMovieCard(context, movie);
      },
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: movie.posterUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  movie.posterUrl!,
                  width: 50,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 75,
                    color: Colors.grey[300],
                    child: const Icon(Icons.movie),
                  ),
                ),
              )
            : Container(
                width: 50,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.movie),
              ),
        title: Text(
          movie.title,
          style: AppTextStyles.h3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${movie.genre} • ${movie.rating}'),
            Text('${movie.durationMin} min'),
            if (movie.director != null) Text('Dir: ${movie.director}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: movie.isActive ? AppColors.success : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                movie.isActive ? 'Ativo' : 'Inativo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditMovieDialog(context, movie);
                break;
              case 'toggle_status':
                _toggleMovieStatus(context, movie);
                break;
              case 'delete':
                _showDeleteConfirmation(context, movie);
                break;
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
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    movie.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(movie.isActive ? 'Desativar' : 'Ativar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                context.read<MovieManagementBloc>().add(const LoadMoviesRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateMovieDialog(BuildContext context) {
    _showMovieFormDialog(context, null);
  }

  void _showEditMovieDialog(BuildContext context, Movie movie) {
    _showMovieFormDialog(context, movie);
  }

  void _showMovieFormDialog(BuildContext context, Movie? movie) {
    final isEditing = movie != null;
    final titleController = TextEditingController(text: movie?.title);
    final synopsisController = TextEditingController(text: movie?.synopsis);
    final durationController = TextEditingController(text: movie?.durationMin.toString());
    final genreController = TextEditingController(text: movie?.genre);
    final ratingController = TextEditingController(text: movie?.rating);
    final directorController = TextEditingController(text: movie?.director);
    final castController = TextEditingController(text: movie?.cast);
    final posterUrlController = TextEditingController(text: movie?.posterUrl);
    final trailerUrlController = TextEditingController(text: movie?.trailerUrl);
    DateTime? releaseDate = movie?.releaseDate;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Editar Filme' : 'Novo Filme'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: synopsisController,
                  decoration: const InputDecoration(
                    labelText: 'Sinopse',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duração (min) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: ratingController,
                        decoration: const InputDecoration(
                          labelText: 'Classificação *',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: LIVRE, 12, 14, 16, 18',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: genreController,
                  decoration: const InputDecoration(
                    labelText: 'Gênero *',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Ação, Drama, Comédia',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: directorController,
                  decoration: const InputDecoration(
                    labelText: 'Diretor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: castController,
                  decoration: const InputDecoration(
                    labelText: 'Elenco',
                    border: OutlineInputBorder(),
                    hintText: 'Separar por vírgula',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: posterUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL do Poster',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: trailerUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL do Trailer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      releaseDate != null
                          ? 'Data de Lançamento: ${releaseDate!.day}/${releaseDate!.month}/${releaseDate!.year}'
                          : 'Data de Lançamento',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: releaseDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          releaseDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  durationController.text.isEmpty ||
                  genreController.text.isEmpty ||
                  ratingController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preencha todos os campos obrigatórios'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (isEditing) {
                final params = UpdateMovieParams(
                  movieId: movie.id,
                  title: titleController.text,
                  synopsis: synopsisController.text.isEmpty ? null : synopsisController.text,
                  durationMin: int.parse(durationController.text),
                  genre: genreController.text,
                  rating: ratingController.text,
                  director: directorController.text.isEmpty ? null : directorController.text,
                  cast: castController.text.isEmpty ? null : castController.text,
                  releaseDate: releaseDate,
                  posterUrl: posterUrlController.text.isEmpty ? null : posterUrlController.text,
                  trailerUrl: trailerUrlController.text.isEmpty ? null : trailerUrlController.text,
                );
                context.read<MovieManagementBloc>().add(UpdateMovieRequested(params: params));
              } else {
                final params = CreateMovieParams(
                  title: titleController.text,
                  synopsis: synopsisController.text.isEmpty ? null : synopsisController.text,
                  durationMin: int.parse(durationController.text),
                  genre: genreController.text,
                  rating: ratingController.text,
                  director: directorController.text.isEmpty ? null : directorController.text,
                  cast: castController.text.isEmpty ? null : castController.text,
                  releaseDate: releaseDate,
                  posterUrl: posterUrlController.text.isEmpty ? null : posterUrlController.text,
                  trailerUrl: trailerUrlController.text.isEmpty ? null : trailerUrlController.text,
                );
                context.read<MovieManagementBloc>().add(CreateMovieRequested(params: params));
              }

              Navigator.of(dialogContext).pop();
            },
            child: Text(isEditing ? 'Salvar' : 'Criar'),
          ),
        ],
      ),
    );
  }

  void _toggleMovieStatus(BuildContext context, Movie movie) {
    final params = UpdateMovieParams(
      movieId: movie.id,
      isActive: !movie.isActive,
    );
    context.read<MovieManagementBloc>().add(UpdateMovieRequested(params: params));
  }

  void _showDeleteConfirmation(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o filme "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MovieManagementBloc>().add(DeleteMovieRequested(movieId: movie.id));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
