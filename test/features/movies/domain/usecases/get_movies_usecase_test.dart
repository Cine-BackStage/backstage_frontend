import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/domain/entities/movie.dart';
import 'package:backstage_frontend/features/movies/domain/repositories/movies_repository.dart';
import 'package:backstage_frontend/features/movies/domain/usecases/movie_usecases.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late GetMoviesUseCaseImpl useCase;
  late MockMoviesRepository mockRepository;

  setUp(() {
    mockRepository = MockMoviesRepository();
    useCase = GetMoviesUseCaseImpl(mockRepository);
  });

  final tMovies = [
    Movie(
      id: '1',
      title: 'Test Movie 1',
      durationMin: 120,
      genre: 'Action',
      rating: 'PG-13',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Movie(
      id: '2',
      title: 'Test Movie 2',
      synopsis: 'A great movie',
      durationMin: 90,
      genre: 'Comedy',
      rating: 'PG',
      director: 'John Director',
      cast: 'Actor 1, Actor 2',
      releaseDate: DateTime(2024, 1, 15),
      posterUrl: 'https://example.com/poster.jpg',
      trailerUrl: 'https://example.com/trailer.mp4',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  test('should call repository.getMovies', () async {
    // Arrange
    when(() => mockRepository.getMovies())
        .thenAnswer((_) async => Right(tMovies));

    // Act
    await useCase.call();

    // Assert
    verify(() => mockRepository.getMovies()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of movies when call is successful', () async {
    // Arrange
    when(() => mockRepository.getMovies())
        .thenAnswer((_) async => Right(tMovies));

    // Act
    final result = await useCase.call();

    // Assert
    expect(result, Right(tMovies));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch movies');
    when(() => mockRepository.getMovies())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call();

    // Assert
    expect(result, const Left(tFailure));
  });
}
