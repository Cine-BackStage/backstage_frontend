import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_detailed_sales_report_usecase.dart';
import '../../domain/usecases/get_employee_report_usecase.dart';
import '../../domain/usecases/get_sales_summary_usecase.dart';
import '../../domain/usecases/get_ticket_sales_report_usecase.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Reports BLoC
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetSalesSummaryUseCase getSalesSummaryUseCase;
  final GetDetailedSalesReportUseCase getDetailedSalesReportUseCase;
  final GetTicketSalesReportUseCase getTicketSalesReportUseCase;
  final GetEmployeeReportUseCase getEmployeeReportUseCase;

  ReportsBloc({
    required this.getSalesSummaryUseCase,
    required this.getDetailedSalesReportUseCase,
    required this.getTicketSalesReportUseCase,
    required this.getEmployeeReportUseCase,
  }) : super(const ReportsInitial()) {
    on<LoadSalesSummary>(_onLoadSalesSummary);
    on<LoadDetailedSalesReport>(_onLoadDetailedSalesReport);
    on<LoadTicketSalesReport>(_onLoadTicketSalesReport);
    on<LoadEmployeeReport>(_onLoadEmployeeReport);
    on<ResetReportsState>(_onResetReportsState);
  }

  Future<void> _onLoadSalesSummary(
    LoadSalesSummary event,
    Emitter<ReportsState> emit,
  ) async {
    print('[Reports BLoC] Loading sales summary...');
    emit(const ReportsLoading());

    final result = await getSalesSummaryUseCase(NoParams());

    result.fold(
      (failure) {
        print('[Reports BLoC] Sales summary failed: ${failure.message}');
        emit(ReportsError(failure.message));
      },
      (summary) {
        print('[Reports BLoC] Sales summary loaded successfully');
        print('[Reports BLoC] Today revenue: ${summary.todayRevenue}, transactions: ${summary.todayTransactions}');
        emit(SalesSummaryLoaded(summary));
      },
    );
  }

  Future<void> _onLoadDetailedSalesReport(
    LoadDetailedSalesReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await getDetailedSalesReportUseCase(
      DetailedSalesReportParams(
        startDate: event.startDate,
        endDate: event.endDate,
        groupBy: event.groupBy,
        cashierCpf: event.cashierCpf,
      ),
    );

    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (report) => emit(DetailedSalesLoaded(report)),
    );
  }

  Future<void> _onLoadTicketSalesReport(
    LoadTicketSalesReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await getTicketSalesReportUseCase(
      TicketSalesReportParams(
        startDate: event.startDate,
        endDate: event.endDate,
        groupBy: event.groupBy,
        movieId: event.movieId,
        employeeCpf: event.employeeCpf,
      ),
    );

    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (report) => emit(TicketSalesLoaded(report)),
    );
  }

  Future<void> _onLoadEmployeeReport(
    LoadEmployeeReport event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await getEmployeeReportUseCase(
      EmployeeReportParams(
        startDate: event.startDate,
        endDate: event.endDate,
        employeeCpf: event.employeeCpf,
      ),
    );

    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (report) => emit(EmployeeReportLoaded(report)),
    );
  }

  void _onResetReportsState(
    ResetReportsState event,
    Emitter<ReportsState> emit,
  ) {
    emit(const ReportsInitial());
  }
}
