import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/reports/domain/entities/sales_summary.dart';
import 'package:backstage_frontend/features/reports/domain/repositories/reports_repository.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_sales_summary_usecase.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  late GetSalesSummaryUseCaseImpl useCase;
  late MockReportsRepository mockRepository;

  setUp(() {
    mockRepository = MockReportsRepository();
    useCase = GetSalesSummaryUseCaseImpl(mockRepository);
  });

  const tSalesSummary = SalesSummary(
    todayRevenue: 1000.0,
    todayTransactions: 10,
    weekRevenue: 5000.0,
    weekTransactions: 50,
    monthRevenue: 20000.0,
    monthTransactions: 200,
    lastMonthRevenue: 18000.0,
    lastMonthTransactions: 180,
    growthPercentage: 11.11,
  );

  test('should call repository.getSalesSummary', () async {
    // Arrange
    when(() => mockRepository.getSalesSummary())
        .thenAnswer((_) async => const Right(tSalesSummary));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.getSalesSummary()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return SalesSummary when call is successful', () async {
    // Arrange
    when(() => mockRepository.getSalesSummary())
        .thenAnswer((_) async => const Right(tSalesSummary));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Right(tSalesSummary));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch sales summary');
    when(() => mockRepository.getSalesSummary())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
