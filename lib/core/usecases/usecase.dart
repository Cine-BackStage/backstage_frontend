/// Use this class when the use case doesn't need any parameters
class NoParams {
  const NoParams();
}

/// Note: Each use case should define its own abstract interface and implementation
///
/// Example pattern:
/// ```dart
/// abstract class LoginUseCase {
///   Future<Either<Failure, Employee>> call(LoginParams params);
/// }
///
/// class LoginUseCaseImpl implements LoginUseCase {
///   final AuthRepository repository;
///
///   LoginUseCaseImpl(this.repository);
///
///   @override
///   Future<Either<Failure, Employee>> call(LoginParams params) async {
///     return await repository.login(params.cpf, params.password);
///   }
/// }
/// ```
