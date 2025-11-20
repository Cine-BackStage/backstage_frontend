import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/presentation/bloc/movie_management_bloc.dart';
import '../../../movies/presentation/bloc/movie_management_event.dart';
import '../../../movies/presentation/bloc/movie_management_state.dart';
import '../../../movies/presentation/widgets/movie_form_dialog.dart';

class MoviesTab extends StatelessWidget {
  final VoidCallback onMovieDeleted;
  final VoidCallback onRefreshAll;

  const MoviesTab({
    super.key,
    required this.onMovieDeleted,
    required this.onRefreshAll,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MovieManagementBloc, MovieManagementState>(
      listener: (context, state) {
        state.whenOrNull(
          saved: (movie) {
            context.showSuccessSnackBar('Filme salvo com sucesso: ${movie.title}');
            onRefreshAll();
          },
          deleted: (movieId) {
            context.showSuccessSnackBar('Filme excluído com sucesso');
            onMovieDeleted(); // Refresh sessions tab
            // Reload movies list after delete
            context.read<MovieManagementBloc>().add(const RefreshMoviesRequested());
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
          loaded: (movies) => _buildMoviesList(context, movies),
          saving: () => const Center(child: CircularProgressIndicator()),
          saved: (_) => const Center(child: CircularProgressIndicator()),
          deleting: () => const Center(child: CircularProgressIndicator()),
          deleted: (_) => const Center(child: CircularProgressIndicator()),
          error: (failure) => _buildErrorView(context, failure.userMessage),
        );
      },
    );
  }

  Widget _buildMoviesList(BuildContext context, List<Movie> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum filme cadastrado',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showMovieDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Filme'),
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
                '${movies.length} filmes',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showMovieDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Novo Filme'),
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
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildMovieCard(context, movie);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMovieDialog(context, movie: movie),
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
                  image: movie.posterUrl != null
                      ? DecorationImage(
                          image: NetworkImage(movie.posterUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: movie.posterUrl == null
                    ? const Icon(Icons.movie, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: AppTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (movie.genre.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.category, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            movie.genre,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.durationMin} min',
                          style: AppTextStyles.bodyMedium,
                        ),
                        if (movie.rating.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.alertWarning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.alertWarning,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              movie.rating,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.alertWarning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: movie.isActive
                                ? AppColors.success.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            movie.isActive ? 'Ativo' : 'Inativo',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: movie.isActive ? AppColors.success : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _showMovieDialog(context, movie: movie),
                    icon: const Icon(Icons.edit),
                    color: AppColors.primary,
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, movie),
                    icon: const Icon(Icons.delete),
                    color: AppColors.error,
                    tooltip: 'Excluir',
                  ),
                ],
              ),
            ],
          ),
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
                context
                    .read<MovieManagementBloc>()
                    .add(const RefreshMoviesRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMovieDialog(BuildContext context, {Movie? movie}) {
    if (movie != null) {
      print('✏️ Editing movie: ${movie.id} - ${movie.title}');
    } else {
      print('➕ Creating new movie');
    }

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<MovieManagementBloc>(),
        child: MovieFormDialog(movie: movie),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Movie movie) {
    print('🗑️ Delete movie clicked: ${movie.id} - ${movie.title}');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja realmente excluir o filme "${movie.title}"?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.alertWarning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.alertWarning,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppColors.alertWarning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Todas as sessões deste filme também serão excluídas.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.alertWarning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              print('✅ Confirming delete movie: ${movie.id}');
              Navigator.of(dialogContext).pop();
              context
                  .read<MovieManagementBloc>()
                  .add(DeleteMovieRequested(movieId: movie.id));
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
