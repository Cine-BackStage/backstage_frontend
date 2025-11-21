import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/domain/entities/movie.dart';
import 'package:backstage_frontend/features/movies/domain/repositories/movies_repository.dart';
import 'package:backstage_frontend/features/movies/domain/usecases/movie_usecases.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late UpdateMovieUseCaseImpl useCase;
  late MockMoviesRepository mockRepository;

  setUp(() {
    mockRepository = MockMoviesRepository();
    useCase = UpdateMovieUseCaseImpl(mockRepository);
  });

  const tMovieId = 'movie-123';
  final tReleaseDate = DateTime(2024, 6, 15);
  final tParams = UpdateMovieParams(
    movieId: tMovieId,
    title: 'Updated Movie',
    durationMin: 130,
    genre: 'Thriller',
    rating: 'R',
    synopsis: 'An updated synopsis',
    director: 'New Director',
    cast: 'New Actor 1, New Actor 2',
    releaseDate: tReleaseDate,
    posterUrl: 'https://example.com/new-poster.jpg',
    trailerUrl: 'https://example.com/new-trailer.mp4',
    isActive: false,
  );

  final tUpdatedMovie = Movie(
    id: tMovieId,
    title: 'Updated Movie',
    synopsis: 'An updated synopsis',
    durationMin: 130,
    genre: 'Thriller',
    rating: 'R',
    director: 'New Director',
    cast: 'New Actor 1, New Actor 2',
    releaseDate: tReleaseDate,
    posterUrl: 'https://example.com/new-poster.jpg',
    trailerUrl: 'https://example.com/new-trailer.mp4',
    isActive: false,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  test('should call repository.updateMovie with correct parameters', () async {
    // Arrange
    when(() => mockRepository.updateMovie(
          movieId: any(named: 'movieId'),
          title: any(named: 'title'),
          durationMin: any(named: 'durationMin'),
          genre: any(named: 'genre'),
          rating: any(named: 'rating'),
          synopsis: any(named: 'synopsis'),
          director: any(named: 'director'),
          cast: any(named: 'cast'),
          releaseDate: any(named: 'releaseDate'),
          posterUrl: any(named: 'posterUrl'),
          trailerUrl: any(named: 'trailerUrl'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => Right(tUpdatedMovie));

    // Act
    await useCase.call(tParams);

    // Assert
    verify(() => mockRepository.updateMovie(
          movieId: tParams.movieId,
          title: tParams.title,
          durationMin: tParams.durationMin,
          genre: tParams.genre,
          rating: tParams.rating,
          synopsis: tParams.synopsis,
          director: tParams.director,
          cast: tParams.cast,
          releaseDate: tParams.releaseDate,
          posterUrl: tParams.posterUrl,
          trailerUrl: tParams.trailerUrl,
          isActive: tParams.isActive,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return updated Movie when call is successful', () async {
    // Arrange
    when(() => mockRepository.updateMovie(
          movieId: any(named: 'movieId'),
          title: any(named: 'title'),
          durationMin: any(named: 'durationMin'),
          genre: any(named: 'genre'),
          rating: any(named: 'rating'),
          synopsis: any(named: 'synopsis'),
          director: any(named: 'director'),
          cast: any(named: 'cast'),
          releaseDate: any(named: 'releaseDate'),
          posterUrl: any(named: 'posterUrl'),
          trailerUrl: any(named: 'trailerUrl'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => Right(tUpdatedMovie));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, Right(tUpdatedMovie));
  });

  test('should return Failure when update fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to update movie', statusCode: 400);
    when(() => mockRepository.updateMovie(
          movieId: any(named: 'movieId'),
          title: any(named: 'title'),
          durationMin: any(named: 'durationMin'),
          genre: any(named: 'genre'),
          rating: any(named: 'rating'),
          synopsis: any(named: 'synopsis'),
          director: any(named: 'director'),
          cast: any(named: 'cast'),
          releaseDate: any(named: 'releaseDate'),
          posterUrl: any(named: 'posterUrl'),
          trailerUrl: any(named: 'trailerUrl'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when movie is not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Movie not found', statusCode: 404);
    when(() => mockRepository.updateMovie(
          movieId: any(named: 'movieId'),
          title: any(named: 'title'),
          durationMin: any(named: 'durationMin'),
          genre: any(named: 'genre'),
          rating: any(named: 'rating'),
          synopsis: any(named: 'synopsis'),
          director: any(named: 'director'),
          cast: any(named: 'cast'),
          releaseDate: any(named: 'releaseDate'),
          posterUrl: any(named: 'posterUrl'),
          trailerUrl: any(named: 'trailerUrl'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should work with partial update parameters', () async {
    // Arrange
    final partialParams = UpdateMovieParams(
      movieId: tMovieId,
      title: 'Only Title Updated',
    );

    final partiallyUpdatedMovie = Movie(
      id: tMovieId,
      title: 'Only Title Updated',
      synopsis: 'Original synopsis',
      durationMin: 120,
      genre: 'Action',
      rating: 'PG-13',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );

    when(() => mockRepository.updateMovie(
          movieId: any(named: 'movieId'),
          title: any(named: 'title'),
          durationMin: any(named: 'durationMin'),
          genre: any(named: 'genre'),
          rating: any(named: 'rating'),
          synopsis: any(named: 'synopsis'),
          director: any(named: 'director'),
          cast: any(named: 'cast'),
          releaseDate: any(named: 'releaseDate'),
          posterUrl: any(named: 'posterUrl'),
          trailerUrl: any(named: 'trailerUrl'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => Right(partiallyUpdatedMovie));

    // Act
    final result = await useCase.call(partialParams);

    // Assert
    expect(result, Right(partiallyUpdatedMovie));
    verify(() => mockRepository.updateMovie(
          movieId: tMovieId,
          title: 'Only Title Updated',
          durationMin: null,
          genre: null,
          rating: null,
          synopsis: null,
          director: null,
          cast: null,
          releaseDate: null,
          posterUrl: null,
          trailerUrl: null,
          isActive: null,
        )).called(1);
  });
}
