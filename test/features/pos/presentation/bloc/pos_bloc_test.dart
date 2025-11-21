import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale_item.dart';
import 'package:backstage_frontend/features/pos/domain/entities/payment.dart';
import 'package:backstage_frontend/features/pos/domain/usecases/pos_usecases.dart';
import 'package:backstage_frontend/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:backstage_frontend/features/pos/presentation/bloc/pos_event.dart';
import 'package:backstage_frontend/features/pos/presentation/bloc/pos_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockCreateSaleUseCase extends Mock implements CreateSaleUseCase {}
class MockGetSaleUseCase extends Mock implements GetSaleUseCase {}
class MockAddItemToSaleUseCase extends Mock implements AddItemToSaleUseCase {}
class MockRemoveItemFromSaleUseCase extends Mock implements RemoveItemFromSaleUseCase {}
class MockValidateDiscountUseCase extends Mock implements ValidateDiscountUseCase {}
class MockApplyDiscountUseCase extends Mock implements ApplyDiscountUseCase {}
class MockAddPaymentUseCase extends Mock implements AddPaymentUseCase {}
class MockRemovePaymentUseCase extends Mock implements RemovePaymentUseCase {}
class MockFinalizeSaleUseCase extends Mock implements FinalizeSaleUseCase {}
class MockCancelSaleUseCase extends Mock implements CancelSaleUseCase {}

void main() {
  late PosBloc posBloc;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockCreateSaleUseCase mockCreateSaleUseCase;
  late MockGetSaleUseCase mockGetSaleUseCase;
  late MockAddItemToSaleUseCase mockAddItemToSaleUseCase;
  late MockRemoveItemFromSaleUseCase mockRemoveItemFromSaleUseCase;
  late MockValidateDiscountUseCase mockValidateDiscountUseCase;
  late MockApplyDiscountUseCase mockApplyDiscountUseCase;
  late MockAddPaymentUseCase mockAddPaymentUseCase;
  late MockRemovePaymentUseCase mockRemovePaymentUseCase;
  late MockFinalizeSaleUseCase mockFinalizeSaleUseCase;
  late MockCancelSaleUseCase mockCancelSaleUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(CreateSaleParams());
    registerFallbackValue(GetSaleParams(saleId: ''));
    registerFallbackValue(AddItemParams(
      saleId: '',
      description: '',
      quantity: 1,
      unitPrice: 0.0,
    ));
    registerFallbackValue(RemoveItemParams(saleId: '', itemId: ''));
    registerFallbackValue(ValidateDiscountParams(code: '', subtotal: 0.0));
    registerFallbackValue(ApplyDiscountParams(saleId: '', code: ''));
    registerFallbackValue(AddPaymentParams(
      saleId: '',
      method: PaymentMethod.cash,
      amount: 0.0,
    ));
    registerFallbackValue(RemovePaymentParams(saleId: '', paymentId: ''));
    registerFallbackValue(FinalizeSaleParams(saleId: ''));
    registerFallbackValue(CancelSaleParams(saleId: ''));
  });

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockCreateSaleUseCase = MockCreateSaleUseCase();
    mockGetSaleUseCase = MockGetSaleUseCase();
    mockAddItemToSaleUseCase = MockAddItemToSaleUseCase();
    mockRemoveItemFromSaleUseCase = MockRemoveItemFromSaleUseCase();
    mockValidateDiscountUseCase = MockValidateDiscountUseCase();
    mockApplyDiscountUseCase = MockApplyDiscountUseCase();
    mockAddPaymentUseCase = MockAddPaymentUseCase();
    mockRemovePaymentUseCase = MockRemovePaymentUseCase();
    mockFinalizeSaleUseCase = MockFinalizeSaleUseCase();
    mockCancelSaleUseCase = MockCancelSaleUseCase();

    posBloc = PosBloc(
      getProductsUseCase: mockGetProductsUseCase,
      createSaleUseCase: mockCreateSaleUseCase,
      getSaleUseCase: mockGetSaleUseCase,
      addItemToSaleUseCase: mockAddItemToSaleUseCase,
      removeItemFromSaleUseCase: mockRemoveItemFromSaleUseCase,
      validateDiscountUseCase: mockValidateDiscountUseCase,
      applyDiscountUseCase: mockApplyDiscountUseCase,
      addPaymentUseCase: mockAddPaymentUseCase,
      removePaymentUseCase: mockRemovePaymentUseCase,
      finalizeSaleUseCase: mockFinalizeSaleUseCase,
      cancelSaleUseCase: mockCancelSaleUseCase,
    );
  });

  tearDown(() {
    posBloc.close();
  });

  final tProducts = [
    Product(
      sku: 'SKU001',
      name: 'Popcorn',
      unitPrice: 15.0,
      category: 'Snacks',
      qtyOnHand: 100,
      reorderLevel: 20,
      isActive: true,
    ),
    Product(
      sku: 'SKU002',
      name: 'Soda',
      unitPrice: 8.0,
      category: 'Beverages',
      qtyOnHand: 50,
      reorderLevel: 10,
      isActive: true,
    ),
  ];

  final tSale = Sale(
    id: 'SALE001',
    companyId: 'COMP001',
    cashierCpf: '123.456.789-00',
    createdAt: DateTime(2024, 1, 1),
    status: 'OPEN',
    subtotal: 0.0,
    discountAmount: 0.0,
    grandTotal: 0.0,
    items: [],
    payments: [],
  );

  final tSaleItem = SaleItem(
    id: 'ITEM001',
    saleId: 'SALE001',
    sku: 'SKU001',
    description: 'Popcorn',
    quantity: 2,
    unitPrice: 15.0,
    totalPrice: 30.0,
    createdAt: DateTime(2024, 1, 1),
  );

  final tPayment = Payment(
    id: 'PAY001',
    saleId: 'SALE001',
    method: PaymentMethod.cash,
    amount: 50.0,
    createdAt: DateTime(2024, 1, 1),
  );

  test('initial state should be PosInitial', () {
    expect(posBloc.state, equals(const PosInitial()));
  });

  group('LoadProducts', () {
    blocTest<PosBloc, PosState>(
      'should emit [PosLoadingProducts, PosProductsLoaded] when products are loaded successfully',
      build: () {
        when(() => mockGetProductsUseCase.call(any()))
            .thenAnswer((_) async => Right(tProducts));
        return posBloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const PosLoadingProducts(),
        PosProductsLoaded(tProducts),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should emit [PosLoadingProducts, PosError] when loading products fails',
      build: () {
        when(() => mockGetProductsUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to load products')));
        return posBloc;
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        const PosLoadingProducts(),
        const PosError(message: 'Não foi possível carregar os produtos. Tente novamente.'),
      ],
    );
  });

  group('CreateSale', () {
    blocTest<PosBloc, PosState>(
      'should create a local sale when products are already loaded',
      build: () {
        return posBloc;
      },
      seed: () => PosProductsLoaded(tProducts),
      act: (bloc) => bloc.add(const CreateSale()),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.products, 'products', tProducts)
            .having((s) => s.sale.status, 'sale.status', 'OPEN')
            .having((s) => s.sale.subtotal, 'sale.subtotal', 0.0),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should create a local sale with buyerCpf',
      build: () {
        return posBloc;
      },
      seed: () => PosProductsLoaded(tProducts),
      act: (bloc) => bloc.add(const CreateSale(buyerCpf: '987.654.321-00')),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.buyerCpf, 'sale.buyerCpf', '987.654.321-00'),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should load products first if not loaded',
      build: () {
        when(() => mockGetProductsUseCase.call(any()))
            .thenAnswer((_) async => Right(tProducts));
        return posBloc;
      },
      act: (bloc) => bloc.add(const CreateSale()),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.products, 'products', tProducts),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should emit error when loading products fails',
      build: () {
        when(() => mockGetProductsUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed')));
        return posBloc;
      },
      act: (bloc) => bloc.add(const CreateSale()),
      expect: () => [
        const PosError(message: 'Não foi possível carregar os produtos. Tente novamente.'),
      ],
    );
  });

  group('LoadSale', () {
    blocTest<PosBloc, PosState>(
      'should emit [PosSaleInProgress] when sale is loaded successfully',
      build: () {
        when(() => mockGetProductsUseCase.call(any()))
            .thenAnswer((_) async => Right(tProducts));
        when(() => mockGetSaleUseCase.call(any()))
            .thenAnswer((_) async => Right(tSale));
        return posBloc;
      },
      act: (bloc) => bloc.add(const LoadSale(saleId: 'SALE001')),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.id, 'sale.id', 'SALE001')
            .having((s) => s.products, 'products', tProducts),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should emit [PosError, PosProductsLoaded] when loading sale fails',
      build: () {
        when(() => mockGetProductsUseCase.call(any()))
            .thenAnswer((_) async => Right(tProducts));
        when(() => mockGetSaleUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Sale not found')));
        return posBloc;
      },
      act: (bloc) => bloc.add(const LoadSale(saleId: 'INVALID')),
      expect: () => [
        const PosError(message: 'Não foi possível carregar a venda. Tente novamente.'),
        PosProductsLoaded(tProducts),
      ],
    );
  });

  group('AddItemToCart', () {
    blocTest<PosBloc, PosState>(
      'should add product item to local cart',
      build: () {
        return posBloc;
      },
      seed: () => PosSaleInProgress(sale: tSale, products: tProducts),
      act: (bloc) => bloc.add(AddItemToCart(
        productSku: 'SKU001',
        description: 'Popcorn',
        unitPrice: 15.0,
        quantity: 2,
      )),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.items.length, 'items.length', 1)
            .having((s) => s.sale.items[0].sku, 'items[0].sku', 'SKU001')
            .having((s) => s.sale.items[0].quantity, 'items[0].quantity', 2)
            .having((s) => s.sale.subtotal, 'subtotal', 30.0)
            .having((s) => s.sale.grandTotal, 'grandTotal', 30.0),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should emit error when stock is insufficient',
      build: () => posBloc,
      seed: () => PosSaleInProgress(
        sale: tSale,
        products: [
          Product(
            sku: 'SKU003',
            name: 'Low Stock',
            unitPrice: 10.0,
            category: 'Test',
            qtyOnHand: 1,
            reorderLevel: 5,
            isActive: true,
          ),
        ],
      ),
      act: (bloc) => bloc.add(AddItemToCart(
        productSku: 'SKU003',
        description: 'Low Stock',
        unitPrice: 10.0,
        quantity: 5,
      )),
      expect: () => [
        isA<PosError>()
            .having((s) => s.message, 'message', contains('Estoque insuficiente')),
        isA<PosSaleInProgress>(),
      ],
    );
  });

  group('RemoveItemFromCart', () {
    blocTest<PosBloc, PosState>(
      'should remove item from cart and recalculate totals',
      build: () => posBloc,
      seed: () => PosSaleInProgress(
        sale: Sale(
          id: 'SALE001',
          companyId: 'COMP001',
          cashierCpf: '123.456.789-00',
          createdAt: DateTime(2024, 1, 1),
          status: 'OPEN',
          subtotal: 30.0,
          discountAmount: 0.0,
          grandTotal: 30.0,
          items: [tSaleItem],
          payments: [],
        ),
        products: tProducts,
      ),
      act: (bloc) => bloc.add(const RemoveItemFromCart(itemId: 'ITEM001')),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.items.length, 'items.length', 0)
            .having((s) => s.sale.subtotal, 'subtotal', 0.0)
            .having((s) => s.sale.grandTotal, 'grandTotal', 0.0),
      ],
    );
  });

  group('ApplyDiscount', () {
    final tDiscountData = {
      'code': 'DISCOUNT10',
      'discountAmount': 10.0,
      'type': 'PERCENTAGE',
      'value': 10.0,
    };

    blocTest<PosBloc, PosState>(
      'should apply discount and update sale totals',
      build: () {
        when(() => mockValidateDiscountUseCase.call(any()))
            .thenAnswer((_) async => Right(tDiscountData));
        return posBloc;
      },
      seed: () => PosSaleInProgress(
        sale: Sale(
          id: 'SALE001',
          companyId: 'COMP001',
          cashierCpf: '123.456.789-00',
          createdAt: DateTime(2024, 1, 1),
          status: 'OPEN',
          subtotal: 100.0,
          discountAmount: 0.0,
          grandTotal: 100.0,
          items: [],
          payments: [],
        ),
        products: tProducts,
      ),
      act: (bloc) => bloc.add(const ApplyDiscount(code: 'DISCOUNT10')),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.discountAmount, 'discountAmount', 10.0)
            .having((s) => s.sale.grandTotal, 'grandTotal', 90.0)
            .having((s) => s.sale.discountCode, 'discountCode', 'DISCOUNT10'),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should emit error when discount validation fails',
      build: () {
        when(() => mockValidateDiscountUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Invalid discount code')));

        return posBloc;
      },
      seed: () => PosSaleInProgress(
        sale: Sale(
          id: 'SALE001',
          companyId: 'COMP001',
          cashierCpf: '123.456.789-00',
          createdAt: DateTime(2024, 1, 1),
          status: 'OPEN',
          subtotal: 100.0,
          discountAmount: 0.0,
          grandTotal: 100.0,
          items: [],
          payments: [],
        ),
        products: tProducts,
      ),
      act: (bloc) => bloc.add(const ApplyDiscount(code: 'INVALID')),
      expect: () => [
        isA<PosError>()
            .having((s) => s.message, 'message', 'Invalid discount code'),
        isA<PosSaleInProgress>(),
      ],
    );
  });

  group('AddPayment', () {
    blocTest<PosBloc, PosState>(
      'should add payment to local sale',
      build: () {
        return posBloc;
      },
      seed: () => PosSaleInProgress(sale: tSale, products: tProducts),
      act: (bloc) => bloc.add(AddPayment(
        method: PaymentMethod.cash,
        amount: 50.0,
      )),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.payments.length, 'payments.length', 1)
            .having((s) => s.sale.payments[0].method, 'payments[0].method', PaymentMethod.cash)
            .having((s) => s.sale.payments[0].amount, 'payments[0].amount', 50.0),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should add payment with authCode for card payments',
      build: () {
        return posBloc;
      },
      seed: () => PosSaleInProgress(sale: tSale, products: tProducts),
      act: (bloc) => bloc.add(AddPayment(
        method: PaymentMethod.card,
        amount: 100.0,
        authCode: 'AUTH123456',
      )),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.payments[0].authCode, 'payments[0].authCode', 'AUTH123456'),
      ],
    );
  });

  group('RemovePayment', () {
    blocTest<PosBloc, PosState>(
      'should remove payment from sale',
      build: () => posBloc,
      seed: () => PosSaleInProgress(
        sale: Sale(
          id: 'SALE001',
          companyId: 'COMP001',
          cashierCpf: '123.456.789-00',
          createdAt: DateTime(2024, 1, 1),
          status: 'OPEN',
          subtotal: 100.0,
          discountAmount: 0.0,
          grandTotal: 100.0,
          items: [],
          payments: [tPayment],
        ),
        products: tProducts,
      ),
      act: (bloc) => bloc.add(const RemovePayment(paymentId: 'PAY001')),
      expect: () => [
        isA<PosSaleInProgress>()
            .having((s) => s.sale.payments.length, 'payments.length', 0),
      ],
    );
  });

  group('FinalizeSale', () {
    blocTest<PosBloc, PosState>(
      'should emit error when sale has no items',
      build: () {
        return posBloc;
      },
      seed: () => PosSaleInProgress(sale: tSale, products: tProducts),
      act: (bloc) => bloc.add(const FinalizeSale()),
      expect: () => [
        const PosError(message: 'Adicione pelo menos um item à venda.'),
        isA<PosSaleInProgress>(),
      ],
    );

    blocTest<PosBloc, PosState>(
      'should emit error when payment is incomplete',
      build: () => posBloc,
      seed: () => PosSaleInProgress(
        sale: Sale(
          id: 'SALE001',
          companyId: 'COMP001',
          cashierCpf: '123.456.789-00',
          createdAt: DateTime(2024, 1, 1),
          status: 'OPEN',
          subtotal: 100.0,
          discountAmount: 0.0,
          grandTotal: 100.0,
          items: [tSaleItem],
          payments: [],
        ),
        products: tProducts,
      ),
      act: (bloc) => bloc.add(const FinalizeSale()),
      expect: () => [
        isA<PosError>()
            .having((s) => s.message, 'message', contains('Pagamento incompleto')),
        isA<PosSaleInProgress>(),
      ],
    );
  });

  group('CancelSale', () {
    blocTest<PosBloc, PosState>(
      'should reset to products loaded state',
      build: () {
        return posBloc;
      },
      seed: () => PosSaleInProgress(sale: tSale, products: tProducts),
      act: (bloc) => bloc.add(const CancelSale()),
      expect: () => [
        PosProductsLoaded(tProducts),
      ],
    );
  });

  group('ResetPos', () {
    blocTest<PosBloc, PosState>(
      'should reset to initial state',
      build: () {
        return posBloc;
      },
      seed: () => PosProductsLoaded(tProducts),
      act: (bloc) => bloc.add(const ResetPos()),
      expect: () => [
        const PosInitial(),
      ],
    );
  });
}
