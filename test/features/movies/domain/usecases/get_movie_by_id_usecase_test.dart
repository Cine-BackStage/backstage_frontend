import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/domain/entities/movie.dart';
import 'package:backstage_frontend/features/movies/domain/repositories/movies_repository.dart';
import 'package:backstage_frontend/features/movies/domain/usecases/movie_usecases.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late GetMovieByIdUseCaseImpl useCase;
  late MockMoviesRepository mockRepository;

  setUp(() {
    mockRepository = MockMoviesRepository();
    useCase = GetMovieByIdUseCaseImpl(mockRepository);
  });

  const tMovieId = 'movie-123';
  final tMovie = Movie(
    id: tMovieId,
    title: 'Test Movie',
    synopsis: 'A great movie',
    durationMin: 120,
    genre: 'Action',
    rating: 'PG-13',
    director: 'John Director',
    cast: 'Actor 1, Actor 2',
    releaseDate: DateTime(2024, 1, 15),
    posterUrl: 'https://example.com/poster.jpg',
    trailerUrl: 'https://example.com/trailer.mp4',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  test('should call repository.getMovieById with correct movieId', () async {
    // Arrange
    when(() => mockRepository.getMovieById(any()))
        .thenAnswer((_) async => Right(tMovie));

    // Act
    await useCase.call(tMovieId);

    // Assert
    verify(() => mockRepository.getMovieById(tMovieId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Movie when call is successful', () async {
    // Arrange
    when(() => mockRepository.getMovieById(any()))
        .thenAnswer((_) async => Right(tMovie));

    // Act
    final result = await useCase.call(tMovieId);

    // Assert
    expect(result, Right(tMovie));
  });

  test('should return Failure when movie is not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Movie not found', statusCode: 404);
    when(() => mockRepository.getMovieById(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tMovieId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch movie');
    when(() => mockRepository.getMovieById(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tMovieId);

    // Assert
    expect(result, const Left(tFailure));
  });
}
