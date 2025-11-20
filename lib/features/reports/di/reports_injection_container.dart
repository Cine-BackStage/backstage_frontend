import '../../../adapters/dependency_injection/service_locator.dart';
import '../data/datasources/reports_remote_datasource.dart';
import '../data/repositories/reports_repository_impl.dart';
import '../domain/repositories/reports_repository.dart';
import '../domain/usecases/get_detailed_sales_report_usecase.dart';
import '../domain/usecases/get_employee_report_usecase.dart';
import '../domain/usecases/get_sales_summary_usecase.dart';
import '../domain/usecases/get_ticket_sales_report_usecase.dart';
import '../presentation/bloc/reports_bloc.dart';

/// Reports injection container
class ReportsInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<ReportsRemoteDataSource>(
      () => ReportsRemoteDataSourceImpl(serviceLocator()),
    );

    // Repositories
    serviceLocator.registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(serviceLocator()),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetSalesSummaryUseCase>(
      () => GetSalesSummaryUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<GetDetailedSalesReportUseCase>(
      () => GetDetailedSalesReportUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<GetTicketSalesReportUseCase>(
      () => GetTicketSalesReportUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<GetEmployeeReportUseCase>(
      () => GetEmployeeReportUseCaseImpl(serviceLocator()),
    );

    // BLoC
    serviceLocator.registerFactory<ReportsBloc>(
      () => ReportsBloc(
        getSalesSummaryUseCase: serviceLocator(),
        getDetailedSalesReportUseCase: serviceLocator(),
        getTicketSalesReportUseCase: serviceLocator(),
        getEmployeeReportUseCase: serviceLocator(),
      ),
    );
  }
}
