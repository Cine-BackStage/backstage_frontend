import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/adjust_stock_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/create_product_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_adjustment_history_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_low_stock_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/get_product_details_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/search_products_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/toggle_product_status_usecase.dart';
import 'package:backstage_frontend/features/inventory/domain/usecases/update_product_usecase.dart';
import 'package:backstage_frontend/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:backstage_frontend/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:backstage_frontend/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

class MockGetInventoryUseCase extends Mock implements GetInventoryUseCase {}
class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}
class MockGetLowStockUseCase extends Mock implements GetLowStockUseCase {}
class MockGetProductDetailsUseCase extends Mock implements GetProductDetailsUseCase {}
class MockAdjustStockUseCase extends Mock implements AdjustStockUseCase {}
class MockGetAdjustmentHistoryUseCase extends Mock implements GetAdjustmentHistoryUseCase {}
class MockCreateProductUseCase extends Mock implements CreateProductUseCase {}
class MockUpdateProductUseCase extends Mock implements UpdateProductUseCase {}
class MockToggleProductStatusUseCase extends Mock implements ToggleProductStatusUseCase {}

void main() {
  late InventoryBloc inventoryBloc;
  late MockGetInventoryUseCase mockGetInventoryUseCase;
  late MockSearchProductsUseCase mockSearchProductsUseCase;
  late MockGetLowStockUseCase mockGetLowStockUseCase;
  late MockGetProductDetailsUseCase mockGetProductDetailsUseCase;
  late MockAdjustStockUseCase mockAdjustStockUseCase;
  late MockGetAdjustmentHistoryUseCase mockGetAdjustmentHistoryUseCase;
  late MockCreateProductUseCase mockCreateProductUseCase;
  late MockUpdateProductUseCase mockUpdateProductUseCase;
  late MockToggleProductStatusUseCase mockToggleProductStatusUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(SearchProductsParams(query: ''));
    registerFallbackValue(GetProductDetailsParams(sku: ''));
    registerFallbackValue(AdjustStockParams(sku: '', quantity: 0, reason: ''));
    registerFallbackValue(GetAdjustmentHistoryParams());
    registerFallbackValue(CreateProductParams(
      sku: '',
      name: '',
      unitPrice: 0,
      category: '',
      initialStock: 0,
    ));
    registerFallbackValue(UpdateProductParams(sku: ''));
    registerFallbackValue(ToggleProductStatusParams(sku: '', isActive: false));
  });

  setUp(() {
    mockGetInventoryUseCase = MockGetInventoryUseCase();
    mockSearchProductsUseCase = MockSearchProductsUseCase();
    mockGetLowStockUseCase = MockGetLowStockUseCase();
    mockGetProductDetailsUseCase = MockGetProductDetailsUseCase();
    mockAdjustStockUseCase = MockAdjustStockUseCase();
    mockGetAdjustmentHistoryUseCase = MockGetAdjustmentHistoryUseCase();
    mockCreateProductUseCase = MockCreateProductUseCase();
    mockUpdateProductUseCase = MockUpdateProductUseCase();
    mockToggleProductStatusUseCase = MockToggleProductStatusUseCase();

    inventoryBloc = InventoryBloc(
      getInventoryUseCase: mockGetInventoryUseCase,
      searchProductsUseCase: mockSearchProductsUseCase,
      getLowStockUseCase: mockGetLowStockUseCase,
      getProductDetailsUseCase: mockGetProductDetailsUseCase,
      adjustStockUseCase: mockAdjustStockUseCase,
      getAdjustmentHistoryUseCase: mockGetAdjustmentHistoryUseCase,
      createProductUseCase: mockCreateProductUseCase,
      updateProductUseCase: mockUpdateProductUseCase,
      toggleProductStatusUseCase: mockToggleProductStatusUseCase,
    );
  });

  tearDown(() {
    inventoryBloc.close();
  });

  const tProduct1 = Product(
    sku: 'SKU001',
    name: 'Popcorn',
    unitPrice: 15.0,
    category: 'Snacks',
    qtyOnHand: 100,
    reorderLevel: 20,
    isActive: true,
  );

  const tProduct2 = Product(
    sku: 'SKU002',
    name: 'Soda',
    unitPrice: 8.0,
    category: 'Beverages',
    qtyOnHand: 50,
    reorderLevel: 10,
    isActive: true,
  );

  const tProducts = [tProduct1, tProduct2];

  final tAdjustment = StockAdjustment(
    id: 'adj-1',
    sku: 'SKU001',
    productName: 'Popcorn',
    type: AdjustmentType.addition,
    quantityBefore: 100,
    quantityAfter: 110,
    quantityChanged: 10,
    reason: 'Restock',
    notes: 'New shipment',
    employeeName: 'John Doe',
    timestamp: DateTime(2024, 1, 1, 10, 0),
  );

  test('initial state should be InventoryInitial', () {
    expect(inventoryBloc.state, equals(const InventoryInitial()));
  });

  group('LoadInventoryRequested', () {
    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryLoaded] when successful',
      build: () {
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProducts));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const LoadInventoryRequested()),
      expect: () => [
        const InventoryLoading(),
        const InventoryLoaded(tProducts),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryError] when fails',
      build: () {
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to load inventory')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const LoadInventoryRequested()),
      expect: () => [
        const InventoryLoading(),
        const InventoryError('Failed to load inventory'),
      ],
    );
  });

  group('SearchProductsRequested', () {
    const tQuery = 'Popcorn';

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryLoaded] when search is successful',
      build: () {
        when(() => mockSearchProductsUseCase.call(any()))
            .thenAnswer((_) async => const Right([tProduct1]));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const SearchProductsRequested(tQuery)),
      expect: () => [
        const InventoryLoading(),
        const InventoryLoaded([tProduct1]),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryError] when search fails',
      build: () {
        when(() => mockSearchProductsUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Search failed')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const SearchProductsRequested(tQuery)),
      expect: () => [
        const InventoryLoading(),
        const InventoryError('Search failed'),
      ],
    );
  });

  group('FilterLowStockRequested', () {
    const tLowStockProduct = Product(
      sku: 'SKU003',
      name: 'Candy',
      unitPrice: 5.0,
      category: 'Snacks',
      qtyOnHand: 5,
      reorderLevel: 20,
      isActive: true,
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryLoaded] with low stock products',
      build: () {
        when(() => mockGetLowStockUseCase.call(any()))
            .thenAnswer((_) async => const Right([tLowStockProduct]));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const FilterLowStockRequested()),
      expect: () => [
        const InventoryLoading(),
        const InventoryLoaded([tLowStockProduct]),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryError] when fails',
      build: () {
        when(() => mockGetLowStockUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to load low stock')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const FilterLowStockRequested()),
      expect: () => [
        const InventoryLoading(),
        const InventoryError('Failed to load low stock'),
      ],
    );
  });

  group('FilterExpiringSoonRequested', () {
    final tExpiringProduct = Product(
      sku: 'SKU004',
      name: 'Milk',
      unitPrice: 6.0,
      category: 'Beverages',
      qtyOnHand: 20,
      reorderLevel: 10,
      isActive: true,
      expiryDate: DateTime.now().add(const Duration(days: 3)),
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryLoaded] with expiring products',
      build: () {
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => Right([tExpiringProduct, tProduct1]));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const FilterExpiringSoonRequested()),
      expect: () => [
        const InventoryLoading(),
        InventoryLoaded([tExpiringProduct]),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryError] when fails',
      build: () {
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to load')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const FilterExpiringSoonRequested()),
      expect: () => [
        const InventoryLoading(),
        const InventoryError('Failed to load'),
      ],
    );
  });

  group('ClearFiltersRequested', () {
    blocTest<InventoryBloc, InventoryState>(
      'should reload inventory by triggering LoadInventoryRequested',
      build: () {
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProducts));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const ClearFiltersRequested()),
      expect: () => [
        const InventoryLoading(),
        const InventoryLoaded(tProducts),
      ],
    );
  });

  group('LoadProductDetailsRequested', () {
    const tSku = 'SKU001';
    final tAdjustments = [tAdjustment];

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryProductDetails] when successful',
      build: () {
        when(() => mockGetProductDetailsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProduct1));
        when(() => mockGetAdjustmentHistoryUseCase.call(any()))
            .thenAnswer((_) async => Right(tAdjustments));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const LoadProductDetailsRequested(tSku)),
      expect: () => [
        const InventoryLoading(),
        InventoryProductDetails(
          product: tProduct1,
          adjustments: tAdjustments,
        ),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryError] when product fetch fails',
      build: () {
        when(() => mockGetProductDetailsUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Product not found')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const LoadProductDetailsRequested(tSku)),
      expect: () => [
        const InventoryLoading(),
        const InventoryError('Product not found'),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit [InventoryLoading, InventoryError] when history fetch fails',
      build: () {
        when(() => mockGetProductDetailsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProduct1));
        when(() => mockGetAdjustmentHistoryUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'History failed')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const LoadProductDetailsRequested(tSku)),
      expect: () => [
        const InventoryLoading(),
        const InventoryError('History failed'),
      ],
    );
  });

  group('AdjustStockRequested', () {
    const tSku = 'SKU001';
    const tQuantity = 10;
    const tReason = 'Reestoque';
    const tNotes = 'New shipment';

    blocTest<InventoryBloc, InventoryState>(
      'should reload inventory after successful adjustment',
      build: () {
        when(() => mockAdjustStockUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProducts));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const AdjustStockRequested(
        sku: tSku,
        quantity: tQuantity,
        reason: tReason,
        notes: tNotes,
      )),
      expect: () => [
        const InventoryLoading(),
        const InventoryLoaded(tProducts),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit InventoryError when adjustment fails',
      build: () {
        when(() => mockAdjustStockUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Adjustment failed')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const AdjustStockRequested(
        sku: tSku,
        quantity: tQuantity,
        reason: tReason,
        notes: tNotes,
      )),
      expect: () => [
        const InventoryError('Adjustment failed'),
      ],
    );
  });

  group('CreateProductRequested', () {
    const tSku = 'SKU005';
    const tName = 'New Product';
    const tUnitPrice = 12.0;
    const tCategory = 'Snacks';
    const tInitialStock = 50;

    blocTest<InventoryBloc, InventoryState>(
      'should reload inventory after successful creation',
      build: () {
        when(() => mockCreateProductUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProduct1));
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProducts));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const CreateProductRequested(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
        category: tCategory,
        initialStock: tInitialStock,
      )),
      expect: () => [
        const InventoryLoading(),
        const InventoryLoaded(tProducts),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit InventoryError when creation fails',
      build: () {
        when(() => mockCreateProductUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Creation failed')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const CreateProductRequested(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
        category: tCategory,
        initialStock: tInitialStock,
      )),
      expect: () => [
        const InventoryError('Creation failed'),
      ],
    );
  });

  group('UpdateProductRequested', () {
    const tSku = 'SKU001';
    const tName = 'Updated Popcorn';
    const tUnitPrice = 18.0;

    blocTest<InventoryBloc, InventoryState>(
      'should reload product details after successful update',
      build: () {
        when(() => mockUpdateProductUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProduct1));
        when(() => mockGetProductDetailsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProduct1));
        when(() => mockGetAdjustmentHistoryUseCase.call(any()))
            .thenAnswer((_) async => Right([tAdjustment]));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const UpdateProductRequested(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
      )),
      expect: () => [
        const InventoryLoading(),
        InventoryProductDetails(
          product: tProduct1,
          adjustments: [tAdjustment],
        ),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit InventoryError when update fails',
      build: () {
        when(() => mockUpdateProductUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Update failed')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const UpdateProductRequested(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
      )),
      expect: () => [
        const InventoryError('Update failed'),
      ],
    );
  });

  group('ToggleProductStatusRequested', () {
    const tSku = 'SKU001';
    const tIsActive = false;

    blocTest<InventoryBloc, InventoryState>(
      'should reload inventory after successful toggle',
      build: () {
        when(() => mockToggleProductStatusUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetInventoryUseCase.call(any()))
            .thenAnswer((_) async => const Right(tProducts));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const ToggleProductStatusRequested(
        sku: tSku,
        isActive: tIsActive,
      )),
      expect: () => [
        const InventoryLoading(),
        const InventoryLoaded(tProducts),
      ],
    );

    blocTest<InventoryBloc, InventoryState>(
      'should emit InventoryError when toggle fails',
      build: () {
        when(() => mockToggleProductStatusUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Toggle failed')));
        return inventoryBloc;
      },
      act: (bloc) => bloc.add(const ToggleProductStatusRequested(
        sku: tSku,
        isActive: tIsActive,
      )),
      expect: () => [
        const InventoryError('Toggle failed'),
      ],
    );
  });
}
