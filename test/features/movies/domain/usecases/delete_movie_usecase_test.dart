import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/domain/repositories/movies_repository.dart';
import 'package:backstage_frontend/features/movies/domain/usecases/movie_usecases.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late DeleteMovieUseCaseImpl useCase;
  late MockMoviesRepository mockRepository;

  setUp(() {
    mockRepository = MockMoviesRepository();
    useCase = DeleteMovieUseCaseImpl(mockRepository);
  });

  const tMovieId = 'movie-123';

  test('should call repository.deleteMovie with correct movieId', () async {
    // Arrange
    when(() => mockRepository.deleteMovie(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(tMovieId);

    // Assert
    verify(() => mockRepository.deleteMovie(tMovieId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Right(null) when deletion is successful', () async {
    // Arrange
    when(() => mockRepository.deleteMovie(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(tMovieId);

    // Assert
    expect(result, const Right(null));
  });

  test('should return Failure when deletion fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to delete movie', statusCode: 400);
    when(() => mockRepository.deleteMovie(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tMovieId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when movie is not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Movie not found', statusCode: 404);
    when(() => mockRepository.deleteMovie(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tMovieId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when unauthorized', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Unauthorized', statusCode: 403);
    when(() => mockRepository.deleteMovie(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tMovieId);

    // Assert
    expect(result, const Left(tFailure));
  });
}
