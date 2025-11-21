import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/domain/entities/movie.dart';
import 'package:backstage_frontend/features/movies/domain/usecases/movie_usecases.dart';
import 'package:backstage_frontend/features/movies/presentation/bloc/movie_management_bloc.dart';
import 'package:backstage_frontend/features/movies/presentation/bloc/movie_management_event.dart';
import 'package:backstage_frontend/features/movies/presentation/bloc/movie_management_state.dart';

class MockGetMoviesUseCase extends Mock implements GetMoviesUseCase {}
class MockGetMovieByIdUseCase extends Mock implements GetMovieByIdUseCase {}
class MockSearchMoviesUseCase extends Mock implements SearchMoviesUseCase {}
class MockCreateMovieUseCase extends Mock implements CreateMovieUseCase {}
class MockUpdateMovieUseCase extends Mock implements UpdateMovieUseCase {}
class MockDeleteMovieUseCase extends Mock implements DeleteMovieUseCase {}

void main() {
  late MovieManagementBloc bloc;
  late MockGetMoviesUseCase mockGetMoviesUseCase;
  late MockCreateMovieUseCase mockCreateMovieUseCase;
  late MockUpdateMovieUseCase mockUpdateMovieUseCase;
  late MockDeleteMovieUseCase mockDeleteMovieUseCase;
  late MockSearchMoviesUseCase mockSearchMoviesUseCase;

  setUpAll(() {
    registerFallbackValue(CreateMovieParams(
      title: '',
      durationMin: 0,
      genre: '',
      rating: '',
    ));
    registerFallbackValue(UpdateMovieParams(movieId: ''));
  });

  setUp(() {
    mockGetMoviesUseCase = MockGetMoviesUseCase();
    mockCreateMovieUseCase = MockCreateMovieUseCase();
    mockUpdateMovieUseCase = MockUpdateMovieUseCase();
    mockDeleteMovieUseCase = MockDeleteMovieUseCase();
    mockSearchMoviesUseCase = MockSearchMoviesUseCase();
    bloc = MovieManagementBloc(
      getMoviesUseCase: mockGetMoviesUseCase,
      createMovieUseCase: mockCreateMovieUseCase,
      updateMovieUseCase: mockUpdateMovieUseCase,
      deleteMovieUseCase: mockDeleteMovieUseCase,
      searchMoviesUseCase: mockSearchMoviesUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tMovies = [
    Movie(
      id: 'movie-1',
      title: 'Test Movie 1',
      durationMin: 120,
      genre: 'Action',
      rating: 'PG-13',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Movie(
      id: 'movie-2',
      title: 'Test Movie 2',
      durationMin: 90,
      genre: 'Comedy',
      rating: 'PG',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  final tMovie = Movie(
    id: 'movie-123',
    title: 'Test Movie',
    synopsis: 'A great movie',
    durationMin: 120,
    genre: 'Action',
    rating: 'PG-13',
    director: 'John Director',
    cast: 'Actor 1, Actor 2',
    releaseDate: DateTime(2024, 6, 15),
    posterUrl: 'https://example.com/poster.jpg',
    trailerUrl: 'https://example.com/trailer.mp4',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  test('initial state should be MovieManagementInitial', () {
    expect(bloc.state, const MovieManagementInitial());
  });

  group('LoadMoviesRequested', () {
    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementLoading, MovieManagementLoaded] when movies are loaded successfully',
      build: () {
        when(() => mockGetMoviesUseCase.call())
            .thenAnswer((_) async => Right(tMovies));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMoviesRequested()),
      expect: () => [
        const MovieManagementLoading(),
        MovieManagementLoaded(movies: tMovies),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementLoading, MovieManagementLoaded] with empty list when no movies exist',
      build: () {
        when(() => mockGetMoviesUseCase.call())
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMoviesRequested()),
      expect: () => [
        const MovieManagementLoading(),
        const MovieManagementLoaded(movies: []),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementLoading, MovieManagementError] when loading fails',
      build: () {
        when(() => mockGetMoviesUseCase.call())
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to load movies')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMoviesRequested()),
      expect: () => [
        const MovieManagementLoading(),
        const MovieManagementError(failure: GenericFailure(message: 'Failed to load movies')),
      ],
    );
  });

  group('RefreshMoviesRequested', () {
    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementLoaded] when movies are refreshed successfully',
      build: () {
        when(() => mockGetMoviesUseCase.call())
            .thenAnswer((_) async => Right(tMovies));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshMoviesRequested()),
      expect: () => [
        MovieManagementLoaded(movies: tMovies),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementError] when refresh fails',
      build: () {
        when(() => mockGetMoviesUseCase.call())
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to refresh movies')));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshMoviesRequested()),
      expect: () => [
        const MovieManagementError(failure: GenericFailure(message: 'Failed to refresh movies')),
      ],
    );
  });

  group('CreateMovieRequested', () {
    final tCreateParams = CreateMovieParams(
      title: 'New Movie',
      durationMin: 120,
      genre: 'Action',
      rating: 'PG-13',
      synopsis: 'An exciting new movie',
      director: 'Jane Director',
      cast: 'Actor 1, Actor 2',
      releaseDate: DateTime(2024, 6, 15),
      posterUrl: 'https://example.com/poster.jpg',
      trailerUrl: 'https://example.com/trailer.mp4',
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementSaving, MovieManagementSaved] when movie is created successfully',
      build: () {
        when(() => mockCreateMovieUseCase.call(any()))
            .thenAnswer((_) async => Right(tMovie));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateMovieRequested(params: tCreateParams)),
      expect: () => [
        const MovieManagementSaving(),
        MovieManagementSaved(movie: tMovie),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementSaving, MovieManagementError] when creation fails',
      build: () {
        when(() => mockCreateMovieUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to create movie')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateMovieRequested(params: tCreateParams)),
      expect: () => [
        const MovieManagementSaving(),
        const MovieManagementError(failure: GenericFailure(message: 'Failed to create movie')),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should call createMovieUseCase with correct parameters',
      build: () {
        when(() => mockCreateMovieUseCase.call(any()))
            .thenAnswer((_) async => Right(tMovie));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateMovieRequested(params: tCreateParams)),
      verify: (_) {
        verify(() => mockCreateMovieUseCase.call(tCreateParams)).called(1);
      },
    );
  });

  group('UpdateMovieRequested', () {
    final tUpdateParams = UpdateMovieParams(
      movieId: 'movie-123',
      title: 'Updated Movie',
      durationMin: 130,
      genre: 'Thriller',
      rating: 'R',
      synopsis: 'An updated synopsis',
      director: 'New Director',
      cast: 'New Actor 1, New Actor 2',
      releaseDate: DateTime(2024, 6, 15),
      posterUrl: 'https://example.com/new-poster.jpg',
      trailerUrl: 'https://example.com/new-trailer.mp4',
      isActive: false,
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementSaving, MovieManagementSaved] when movie is updated successfully',
      build: () {
        when(() => mockUpdateMovieUseCase.call(any()))
            .thenAnswer((_) async => Right(tMovie));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateMovieRequested(params: tUpdateParams)),
      expect: () => [
        const MovieManagementSaving(),
        MovieManagementSaved(movie: tMovie),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementSaving, MovieManagementError] when update fails',
      build: () {
        when(() => mockUpdateMovieUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to update movie')));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateMovieRequested(params: tUpdateParams)),
      expect: () => [
        const MovieManagementSaving(),
        const MovieManagementError(failure: GenericFailure(message: 'Failed to update movie')),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should call updateMovieUseCase with correct parameters',
      build: () {
        when(() => mockUpdateMovieUseCase.call(any()))
            .thenAnswer((_) async => Right(tMovie));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateMovieRequested(params: tUpdateParams)),
      verify: (_) {
        verify(() => mockUpdateMovieUseCase.call(tUpdateParams)).called(1);
      },
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementSaving, MovieManagementError] when movie is not found',
      build: () {
        when(() => mockUpdateMovieUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Movie not found', statusCode: 404)));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateMovieRequested(params: tUpdateParams)),
      expect: () => [
        const MovieManagementSaving(),
        const MovieManagementError(failure: GenericFailure(message: 'Movie not found', statusCode: 404)),
      ],
    );
  });

  group('DeleteMovieRequested', () {
    const tMovieId = 'movie-123';

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementDeleting, MovieManagementDeleted] when movie is deleted successfully',
      build: () {
        when(() => mockDeleteMovieUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteMovieRequested(movieId: tMovieId)),
      expect: () => [
        const MovieManagementDeleting(),
        const MovieManagementDeleted(movieId: tMovieId),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementDeleting, MovieManagementError] when deletion fails',
      build: () {
        when(() => mockDeleteMovieUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to delete movie')));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteMovieRequested(movieId: tMovieId)),
      expect: () => [
        const MovieManagementDeleting(),
        const MovieManagementError(failure: GenericFailure(message: 'Failed to delete movie')),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should call deleteMovieUseCase with correct movieId',
      build: () {
        when(() => mockDeleteMovieUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteMovieRequested(movieId: tMovieId)),
      verify: (_) {
        verify(() => mockDeleteMovieUseCase.call(tMovieId)).called(1);
      },
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementDeleting, MovieManagementError] when movie is not found',
      build: () {
        when(() => mockDeleteMovieUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Movie not found', statusCode: 404)));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteMovieRequested(movieId: tMovieId)),
      expect: () => [
        const MovieManagementDeleting(),
        const MovieManagementError(failure: GenericFailure(message: 'Movie not found', statusCode: 404)),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementDeleting, MovieManagementError] when unauthorized',
      build: () {
        when(() => mockDeleteMovieUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Unauthorized', statusCode: 403)));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteMovieRequested(movieId: tMovieId)),
      expect: () => [
        const MovieManagementDeleting(),
        const MovieManagementError(failure: GenericFailure(message: 'Unauthorized', statusCode: 403)),
      ],
    );
  });

  group('SearchMoviesRequested', () {
    const tQuery = 'action';

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementLoading, MovieManagementLoaded] when search is successful',
      build: () {
        when(() => mockSearchMoviesUseCase.call(any()))
            .thenAnswer((_) async => Right(tMovies));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchMoviesRequested(query: tQuery)),
      expect: () => [
        const MovieManagementLoading(),
        MovieManagementLoaded(movies: tMovies),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementLoading, MovieManagementLoaded] with empty list when no movies match query',
      build: () {
        when(() => mockSearchMoviesUseCase.call(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchMoviesRequested(query: tQuery)),
      expect: () => [
        const MovieManagementLoading(),
        const MovieManagementLoaded(movies: []),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should emit [MovieManagementLoading, MovieManagementError] when search fails',
      build: () {
        when(() => mockSearchMoviesUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Search failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchMoviesRequested(query: tQuery)),
      expect: () => [
        const MovieManagementLoading(),
        const MovieManagementError(failure: GenericFailure(message: 'Search failed')),
      ],
    );

    blocTest<MovieManagementBloc, MovieManagementState>(
      'should call searchMoviesUseCase with correct query',
      build: () {
        when(() => mockSearchMoviesUseCase.call(any()))
            .thenAnswer((_) async => Right(tMovies));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchMoviesRequested(query: tQuery)),
      verify: (_) {
        verify(() => mockSearchMoviesUseCase.call(tQuery)).called(1);
      },
    );
  });
}
