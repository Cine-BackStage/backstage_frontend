import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/entities/feature_info.dart';
import '../../domain/errors/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../../../../design_system/theme/app_colors.dart';

/// Implementation of authentication repository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AuthException, User>> login(Credentials credentials) async {
    try {
      // Call remote data source
      final response = await remoteDataSource.login(
        credentials.cpf,
        credentials.password,
      );

      // Save auth data locally
      await localDataSource.saveAuthToken(
        response.token,
        response.expiryDate,
      );
      await localDataSource.saveUser(response.user);

      // TODO: Add analytics event for successful login
      // TODO: Initialize user-specific services (notifications, etc.)

      return Right(response.user.toEntity());
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NetworkException());
    }
  }

  @override
  Future<Either<AuthException, void>> logout() async {
    try {
      // TODO: Call backend to invalidate token
      // await remoteDataSource.logout();

      // Clear local auth data
      await localDataSource.clearAuth();

      // TODO: Clear any cached data
      // TODO: Add analytics event for logout

      return const Right(null);
    } catch (e) {
      return Left(NetworkException());
    }
  }

  @override
  Future<Either<AuthException, User?>> checkAuthStatus() async {
    try {
      // Check if token exists
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        return const Right(null);
      }

      // Check if token is expired
      final isExpired = await localDataSource.isTokenExpired();
      if (isExpired) {
        await localDataSource.clearAuth();
        return Left(TokenExpiredException());
      }

      // Get user from local storage
      final userDto = await localDataSource.getUser();
      if (userDto == null) {
        await localDataSource.clearAuth();
        return const Right(null);
      }

      // TODO: Validate token with backend
      // final isValid = await remoteDataSource.validateToken(token);
      // if (!isValid) {
      //   await localDataSource.clearAuth();
      //   return Left(TokenExpiredException());
      // }

      return Right(userDto.toEntity());
    } catch (e) {
      return Left(NetworkException());
    }
  }

  @override
  Future<Either<AuthException, User?>> getCurrentUser() async {
    try {
      final userDto = await localDataSource.getUser();
      return Right(userDto?.toEntity());
    } catch (e) {
      return Left(NetworkException());
    }
  }

  @override
  Future<Either<AuthException, void>> requestPasswordReset(String cpf) async {
    try {
      await remoteDataSource.requestPasswordReset(cpf);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(NetworkException());
    }
  }

  @override
  Future<Either<AuthException, List<FeatureInfo>>> getFeatures() async {
    try {
      // TODO: Fetch features from backend or feature flags service
      // For now, return static list
      await Future.delayed(const Duration(milliseconds: 500));

      final features = [
        const FeatureInfo(
          title: 'Ponto de Venda',
          description: 'Venda de ingressos e produtos de forma rápida e intuitiva',
          icon: Icons.point_of_sale,
          color: AppColors.orangeSpotlight,
        ),
        const FeatureInfo(
          title: 'Gestão de Sessões',
          description: 'Controle completo de sessões e salas de cinema',
          icon: Icons.theaters,
          color: AppColors.goldenReel,
        ),
        const FeatureInfo(
          title: 'Controle de Estoque',
          description: 'Gerenciamento eficiente de produtos e suprimentos',
          icon: Icons.inventory,
          color: AppColors.popcornYellow,
        ),
        const FeatureInfo(
          title: 'Relatórios e Análises',
          description: 'Dados em tempo real para melhor tomada de decisão',
          icon: Icons.analytics,
          color: AppColors.successGreen,
        ),
      ];

      return Right(features);
    } catch (e) {
      return Left(NetworkException());
    }
  }
}
