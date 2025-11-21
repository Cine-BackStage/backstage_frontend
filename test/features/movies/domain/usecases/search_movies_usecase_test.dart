import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/domain/entities/movie.dart';
import 'package:backstage_frontend/features/movies/domain/repositories/movies_repository.dart';
import 'package:backstage_frontend/features/movies/domain/usecases/movie_usecases.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late SearchMoviesUseCaseImpl useCase;
  late MockMoviesRepository mockRepository;

  setUp(() {
    mockRepository = MockMoviesRepository();
    useCase = SearchMoviesUseCaseImpl(mockRepository);
  });

  const tQuery = 'action';
  final tMovies = [
    Movie(
      id: '1',
      title: 'Action Movie 1',
      durationMin: 120,
      genre: 'Action',
      rating: 'PG-13',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Movie(
      id: '2',
      title: 'Action Movie 2',
      durationMin: 90,
      genre: 'Action',
      rating: 'R',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  test('should call repository.searchMovies with correct query', () async {
    // Arrange
    when(() => mockRepository.searchMovies(any()))
        .thenAnswer((_) async => Right(tMovies));

    // Act
    await useCase.call(tQuery);

    // Assert
    verify(() => mockRepository.searchMovies(tQuery)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of movies when search is successful', () async {
    // Arrange
    when(() => mockRepository.searchMovies(any()))
        .thenAnswer((_) async => Right(tMovies));

    // Act
    final result = await useCase.call(tQuery);

    // Assert
    expect(result, Right(tMovies));
  });

  test('should return empty list when no movies match query', () async {
    // Arrange
    when(() => mockRepository.searchMovies(any()))
        .thenAnswer((_) async => const Right([]));

    // Act
    final result = await useCase.call(tQuery);

    // Assert
    result.fold(
      (failure) => fail('Should return Right'),
      (movies) => expect(movies, isEmpty),
    );
  });

  test('should return Failure when search fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Search failed');
    when(() => mockRepository.searchMovies(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tQuery);

    // Assert
    expect(result, const Left(tFailure));
  });
}
