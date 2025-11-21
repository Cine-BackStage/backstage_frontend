import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/domain/entities/movie.dart';
import 'package:backstage_frontend/features/movies/domain/repositories/movies_repository.dart';
import 'package:backstage_frontend/features/movies/domain/usecases/movie_usecases.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late CreateMovieUseCaseImpl useCase;
  late MockMoviesRepository mockRepository;

  setUp(() {
    mockRepository = MockMoviesRepository();
    useCase = CreateMovieUseCaseImpl(mockRepository);
  });

  final tReleaseDate = DateTime(2024, 6, 15);
  final tParams = CreateMovieParams(
    title: 'New Movie',
    durationMin: 120,
    genre: 'Action',
    rating: 'PG-13',
    synopsis: 'An exciting new movie',
    director: 'Jane Director',
    cast: 'Actor 1, Actor 2, Actor 3',
    releaseDate: tReleaseDate,
    posterUrl: 'https://example.com/poster.jpg',
    trailerUrl: 'https://example.com/trailer.mp4',
  );

  final tMovie = Movie(
    id: 'movie-123',
    title: 'New Movie',
    synopsis: 'An exciting new movie',
    durationMin: 120,
    genre: 'Action',
    rating: 'PG-13',
    director: 'Jane Director',
    cast: 'Actor 1, Actor 2, Actor 3',
    releaseDate: tReleaseDate,
    posterUrl: 'https://example.com/poster.jpg',
    trailerUrl: 'https://example.com/trailer.mp4',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  test('should call repository.createMovie with correct parameters', () async {
    // Arrange
    when(() => mockRepository.createMovie(
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
        )).thenAnswer((_) async => Right(tMovie));

    // Act
    await useCase.call(tParams);

    // Assert
    verify(() => mockRepository.createMovie(
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
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return created Movie when call is successful', () async {
    // Arrange
    when(() => mockRepository.createMovie(
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
        )).thenAnswer((_) async => Right(tMovie));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, Right(tMovie));
  });

  test('should return Failure when creation fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to create movie', statusCode: 400);
    when(() => mockRepository.createMovie(
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
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should work with minimal required parameters', () async {
    // Arrange
    final minimalParams = CreateMovieParams(
      title: 'Minimal Movie',
      durationMin: 90,
      genre: 'Drama',
      rating: 'PG',
    );

    final minimalMovie = Movie(
      id: 'movie-456',
      title: 'Minimal Movie',
      durationMin: 90,
      genre: 'Drama',
      rating: 'PG',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    when(() => mockRepository.createMovie(
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
        )).thenAnswer((_) async => Right(minimalMovie));

    // Act
    final result = await useCase.call(minimalParams);

    // Assert
    expect(result, Right(minimalMovie));
  });
}
