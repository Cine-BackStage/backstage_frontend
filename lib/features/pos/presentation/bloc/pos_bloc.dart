import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/entities/payment.dart';
import '../../domain/usecases/pos_usecases.dart';
import 'pos_event.dart';
import 'pos_state.dart';

/// POS BLoC for managing point of sale operations
class PosBloc extends Bloc<PosEvent, PosState> {
  final GetProductsUseCase getProductsUseCase;
  final CreateSaleUseCase createSaleUseCase;
  final GetSaleUseCase getSaleUseCase;
  final AddItemToSaleUseCase addItemToSaleUseCase;
  final RemoveItemFromSaleUseCase removeItemFromSaleUseCase;
  final ValidateDiscountUseCase validateDiscountUseCase;
  final ApplyDiscountUseCase applyDiscountUseCase;
  final AddPaymentUseCase addPaymentUseCase;
  final RemovePaymentUseCase removePaymentUseCase;
  final FinalizeSaleUseCase finalizeSaleUseCase;
  final CancelSaleUseCase cancelSaleUseCase;

  PosBloc({
    required this.getProductsUseCase,
    required this.createSaleUseCase,
    required this.getSaleUseCase,
    required this.addItemToSaleUseCase,
    required this.removeItemFromSaleUseCase,
    required this.validateDiscountUseCase,
    required this.applyDiscountUseCase,
    required this.addPaymentUseCase,
    required this.removePaymentUseCase,
    required this.finalizeSaleUseCase,
    required this.cancelSaleUseCase,
  }) : super(const PosInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateSale>(_onCreateSale);
    on<LoadSale>(_onLoadSale);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<ApplyDiscount>(_onApplyDiscount);
    on<AddPayment>(_onAddPayment);
    on<RemovePayment>(_onRemovePayment);
    on<FinalizeSale>(_onFinalizeSale);
    on<CancelSale>(_onCancelSale);
    on<ResetPos>(_onReset);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<PosState> emit,
  ) async {
    emit(const PosLoadingProducts());

    final result = await getProductsUseCase(NoParams());

    result.fold(
      (failure) {
        // Log the actual error for debugging
        developer.log(
          'Failed to load products',
          error: failure.message,
          name: 'PosBloc',
        );
        emit(const PosError(
          message: 'Não foi possível carregar os produtos. Tente novamente.',
        ));
      },
      (products) => emit(PosProductsLoaded(products)),
    );
  }

  Future<void> _onCreateSale(
    CreateSale event,
    Emitter<PosState> emit,
  ) async {
    // Get products first if not loaded
    final currentProducts = state.maybeWhen(
      productsLoaded: (products) => products,
      saleInProgress: (_, products, __) => products,
      error: (_, products, __) => products,
      orElse: () => null,
    );

    if (currentProducts == null) {
      final productsResult = await getProductsUseCase(NoParams());

      await productsResult.fold(
        (failure) async {
          developer.log(
            'Failed to load products before creating sale',
            error: failure.message,
            name: 'PosBloc',
          );
          emit(const PosError(
            message: 'Não foi possível carregar os produtos. Tente novamente.',
          ));
        },
        (products) async {
          _createLocalSale(event, emit, products);
        },
      );
    } else {
      _createLocalSale(event, emit, currentProducts);
    }
  }

  void _createLocalSale(
    CreateSale event,
    Emitter<PosState> emit,
    dynamic products,
  ) {
    // Create a local sale (not persisted to backend yet)
    final localSale = Sale(
      id: 'LOCAL_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
      companyId: 'temp', // Will be set by backend
      cashierCpf: 'temp', // Will be set by backend
      buyerCpf: event.buyerCpf,
      createdAt: DateTime.now(),
      status: 'OPEN',
      subtotal: 0.0,
      discountAmount: 0.0,
      grandTotal: 0.0,
      items: [],
      payments: [],
    );

    emit(PosSaleInProgress(
      sale: localSale,
      products: products,
    ));
  }

  Future<void> _onLoadSale(
    LoadSale event,
    Emitter<PosState> emit,
  ) async {
    // Get products first
    final productsResult = await getProductsUseCase(NoParams());

    await productsResult.fold(
      (failure) async {
        developer.log(
          'Failed to load products before loading sale',
          error: failure.message,
          name: 'PosBloc',
        );
        emit(const PosError(
          message: 'Não foi possível carregar os produtos. Tente novamente.',
        ));
      },
      (products) async {
        final saleResult = await getSaleUseCase(
          GetSaleParams(saleId: event.saleId),
        );

        saleResult.fold(
          (failure) {
            developer.log(
              'Failed to load sale',
              error: failure.message,
              name: 'PosBloc',
            );
            emit(const PosError(
              message: 'Não foi possível carregar a venda. Tente novamente.',
            ));
            emit(PosProductsLoaded(products));
          },
          (sale) => emit(PosSaleInProgress(
            sale: sale,
            products: products,
          )),
        );
      },
    );
  }

  Future<void> _onAddItemToCart(
    AddItemToCart event,
    Emitter<PosState> emit,
  ) async {
    final currentState = state;

    if (currentState is PosSaleInProgress) {
      // Find the product to check stock
      final product = currentState.products.firstWhere(
        (p) => p.sku == event.productSku,
        orElse: () => throw Exception('Product not found'),
      );

      // Calculate total quantity already in cart for this product
      final quantityInCart = currentState.sale.items
          .where((item) => item.sku == event.productSku)
          .fold<int>(0, (sum, item) => sum + item.quantity);

      // Check if we have enough stock
      final availableStock = product.qtyOnHand - quantityInCart;
      if (availableStock < event.quantity) {
        emit(PosError(
          message: availableStock > 0
              ? 'Estoque insuficiente. Disponível: $availableStock unidade(s).'
              : 'Produto sem estoque disponível.',
          products: currentState.products,
          sale: currentState.sale,
        ));
        emit(PosSaleInProgress(
          sale: currentState.sale,
          products: currentState.products,
          discountCode: currentState.discountCode,
        ));
        return;
      }

      // Create new item locally
      final newItem = SaleItem(
        id: 'ITEM_${DateTime.now().millisecondsSinceEpoch}',
        saleId: currentState.sale.id,
        sku: event.productSku,
        sessionId: event.sessionId,
        seatId: event.seatId,
        description: event.description,
        quantity: event.quantity,
        unitPrice: event.unitPrice,
        totalPrice: event.unitPrice * event.quantity,
        createdAt: DateTime.now(),
      );

      // Add item to local sale
      final updatedItems = [...currentState.sale.items, newItem];

      // Recalculate totals
      final subtotal = updatedItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final grandTotal = subtotal - currentState.sale.discountAmount;

      final updatedSale = Sale(
        id: currentState.sale.id,
        companyId: currentState.sale.companyId,
        cashierCpf: currentState.sale.cashierCpf,
        buyerCpf: currentState.sale.buyerCpf,
        createdAt: currentState.sale.createdAt,
        status: currentState.sale.status,
        subtotal: subtotal,
        discountAmount: currentState.sale.discountAmount,
        grandTotal: grandTotal,
        items: updatedItems,
        payments: currentState.sale.payments,
        discountCode: currentState.sale.discountCode,
      );

      emit(PosSaleInProgress(
        sale: updatedSale,
        products: currentState.products,
        discountCode: currentState.discountCode,
      ));
    }
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCart event,
    Emitter<PosState> emit,
  ) async {
    final currentState = state;

    if (currentState is PosSaleInProgress) {
      // Remove item locally
      final updatedItems = currentState.sale.items
          .where((item) => item.id != event.itemId)
          .toList();

      // Recalculate totals
      final subtotal = updatedItems.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final grandTotal = subtotal - currentState.sale.discountAmount;

      final updatedSale = Sale(
        id: currentState.sale.id,
        companyId: currentState.sale.companyId,
        cashierCpf: currentState.sale.cashierCpf,
        buyerCpf: currentState.sale.buyerCpf,
        createdAt: currentState.sale.createdAt,
        status: currentState.sale.status,
        subtotal: subtotal,
        discountAmount: currentState.sale.discountAmount,
        grandTotal: grandTotal,
        items: updatedItems,
        payments: currentState.sale.payments,
        discountCode: currentState.sale.discountCode,
      );

      emit(PosSaleInProgress(
        sale: updatedSale,
        products: currentState.products,
        discountCode: currentState.discountCode,
      ));
    }
  }

  Future<void> _onApplyDiscount(
    ApplyDiscount event,
    Emitter<PosState> emit,
  ) async {
    final currentState = state;

    if (currentState is PosSaleInProgress) {
      // Validate discount and get discount amount
      final result = await validateDiscountUseCase(
        ValidateDiscountParams(
          code: event.code,
          subtotal: currentState.sale.subtotal,
        ),
      );

      result.fold(
        (failure) {
          // Log the actual error for debugging
          developer.log(
            'Failed to validate discount',
            error: failure.message,
            name: 'PosBloc',
          );

          // Emit error with user-friendly message
          emit(PosError(
            message: failure.message,
            products: currentState.products,
            sale: currentState.sale,
          ));

          // Immediately recover to previous state
          emit(PosSaleInProgress(
            sale: currentState.sale,
            products: currentState.products,
            discountCode: currentState.discountCode,
          ));
        },
        (discountData) {
          // Calculate new totals locally
          final discountAmount = (discountData['discountAmount'] as num).toDouble();
          final newGrandTotal = currentState.sale.subtotal - discountAmount;

          final updatedSale = Sale(
            id: currentState.sale.id,
            companyId: currentState.sale.companyId,
            cashierCpf: currentState.sale.cashierCpf,
            buyerCpf: currentState.sale.buyerCpf,
            createdAt: currentState.sale.createdAt,
            status: currentState.sale.status,
            subtotal: currentState.sale.subtotal,
            discountAmount: discountAmount,
            grandTotal: newGrandTotal,
            items: currentState.sale.items,
            payments: currentState.sale.payments,
            discountCode: event.code,
          );

          emit(PosSaleInProgress(
            sale: updatedSale,
            products: currentState.products,
            discountCode: event.code,
          ));
        },
      );
    }
  }

  Future<void> _onAddPayment(
    AddPayment event,
    Emitter<PosState> emit,
  ) async {
    final currentState = state;

    if (currentState is PosSaleInProgress) {
      // Create new payment locally
      final newPayment = Payment(
        id: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        saleId: currentState.sale.id,
        method: event.method,
        amount: event.amount,
        authCode: event.authCode,
        createdAt: DateTime.now(),
      );

      // Add payment to local sale
      final updatedPayments = [...currentState.sale.payments, newPayment];

      final updatedSale = Sale(
        id: currentState.sale.id,
        companyId: currentState.sale.companyId,
        cashierCpf: currentState.sale.cashierCpf,
        buyerCpf: currentState.sale.buyerCpf,
        createdAt: currentState.sale.createdAt,
        status: currentState.sale.status,
        subtotal: currentState.sale.subtotal,
        discountAmount: currentState.sale.discountAmount,
        grandTotal: currentState.sale.grandTotal,
        items: currentState.sale.items,
        payments: updatedPayments,
        discountCode: currentState.sale.discountCode,
      );

      emit(PosSaleInProgress(
        sale: updatedSale,
        products: currentState.products,
        discountCode: currentState.discountCode,
      ));
    }
  }

  Future<void> _onRemovePayment(
    RemovePayment event,
    Emitter<PosState> emit,
  ) async {
    final currentState = state;

    if (currentState is PosSaleInProgress) {
      // Remove payment locally
      final updatedPayments = currentState.sale.payments
          .where((payment) => payment.id != event.paymentId)
          .toList();

      final updatedSale = Sale(
        id: currentState.sale.id,
        companyId: currentState.sale.companyId,
        cashierCpf: currentState.sale.cashierCpf,
        buyerCpf: currentState.sale.buyerCpf,
        createdAt: currentState.sale.createdAt,
        status: currentState.sale.status,
        subtotal: currentState.sale.subtotal,
        discountAmount: currentState.sale.discountAmount,
        grandTotal: currentState.sale.grandTotal,
        items: currentState.sale.items,
        payments: updatedPayments,
        discountCode: currentState.sale.discountCode,
      );

      emit(PosSaleInProgress(
        sale: updatedSale,
        products: currentState.products,
        discountCode: currentState.discountCode,
      ));
    }
  }

  Future<void> _onFinalizeSale(
    FinalizeSale event,
    Emitter<PosState> emit,
  ) async {
    final currentState = state;

    if (currentState is PosSaleInProgress) {
      // Check if there are items
      if (currentState.sale.items.isEmpty) {
        emit(const PosError(
          message: 'Adicione pelo menos um item à venda.',
        ));
        emit(PosSaleInProgress(
          sale: currentState.sale,
          products: currentState.products,
          discountCode: currentState.discountCode,
        ));
        return;
      }

      // Check if payment is complete
      if (!currentState.sale.isPaymentComplete) {
        emit(PosError(
          message:
              'Pagamento incompleto. Pago: R\$ ${currentState.sale.totalPaid.toStringAsFixed(2)}, Necessário: R\$ ${currentState.sale.grandTotal.toStringAsFixed(2)}',
        ));
        emit(PosSaleInProgress(
          sale: currentState.sale,
          products: currentState.products,
          discountCode: currentState.discountCode,
        ));
        return;
      }

      emit(PosProcessingPayment(
        sale: currentState.sale,
        products: currentState.products,
      ));

      // Step 1: Create sale on backend
      final createResult = await createSaleUseCase(
        CreateSaleParams(buyerCpf: currentState.sale.buyerCpf),
      );

      final createdSaleResult = await createResult.fold(
        (failure) async {
          developer.log(
            'Failed to create sale on backend',
            error: failure.message,
            name: 'PosBloc',
          );
          emit(const PosError(
            message: 'Não foi possível finalizar a venda. Tente novamente.',
          ));
          emit(PosSaleInProgress(
            sale: currentState.sale,
            products: currentState.products,
            discountCode: currentState.discountCode,
          ));
          return null;
        },
        (createdSale) async => createdSale,
      );

      if (createdSaleResult == null) return;

      // Step 2: Add all items
      for (final item in currentState.sale.items) {
        final itemResult = await addItemToSaleUseCase(
          AddItemParams(
            saleId: createdSaleResult.id,
            sku: item.sku,
            sessionId: item.sessionId,
            seatId: item.seatId,
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ),
        );

        final itemError = await itemResult.fold(
          (failure) async {
            developer.log(
              'Failed to add item during finalization',
              error: failure.message,
              name: 'PosBloc',
            );

            // Check if it's a stock/inventory error (409 Conflict or stock-related message)
            if (failure.statusCode == 409 ||
                failure.message.toLowerCase().contains('estoque') ||
                failure.message.toLowerCase().contains('stock') ||
                failure.message.toLowerCase().contains('inventory')) {
              return 'STOCK_ERROR';
            }
            return 'ERROR';
          },
          (_) async => null,
        );

        if (itemError != null) {
          if (itemError == 'STOCK_ERROR') {
            // Stock issue - reload products and show specific error
            developer.log(
              'Stock validation failed during finalization - reloading products',
              name: 'PosBloc',
            );

            // Reload products to get updated stock
            final productsResult = await getProductsUseCase(NoParams());

            await productsResult.fold(
              (failure) async {
                emit(const PosError(
                  message: 'Estoque insuficiente. Não foi possível atualizar produtos.',
                ));
                emit(PosSaleInProgress(
                  sale: currentState.sale,
                  products: currentState.products,
                  discountCode: currentState.discountCode,
                ));
              },
              (updatedProducts) async {
                emit(const PosError(
                  message: 'Estoque insuficiente. Os produtos foram atualizados. Verifique a disponibilidade.',
                ));
                emit(PosSaleInProgress(
                  sale: currentState.sale,
                  products: updatedProducts,
                  discountCode: currentState.discountCode,
                ));
              },
            );
          } else {
            emit(const PosError(
              message: 'Erro ao adicionar itens. Tente novamente.',
            ));
            emit(PosSaleInProgress(
              sale: currentState.sale,
              products: currentState.products,
              discountCode: currentState.discountCode,
            ));
          }
          return;
        }
      }

      // Step 3: Apply discount if any
      if (currentState.discountCode.isNotEmpty) {
        final discountResult = await applyDiscountUseCase(
          ApplyDiscountParams(
            saleId: createdSaleResult.id,
            code: currentState.discountCode,
          ),
        );

        final discountFailed = await discountResult.fold(
          (failure) async {
            developer.log(
              'Failed to apply discount during finalization',
              error: failure.message,
              name: 'PosBloc',
            );
            return true;
          },
          (_) async => false,
        );

        if (discountFailed) {
          emit(const PosError(
            message: 'Erro ao aplicar desconto. Tente novamente.',
          ));
          emit(PosSaleInProgress(
            sale: currentState.sale,
            products: currentState.products,
            discountCode: currentState.discountCode,
          ));
          return;
        }
      }

      // Step 4: Add all payments
      for (final payment in currentState.sale.payments) {
        final paymentResult = await addPaymentUseCase(
          AddPaymentParams(
            saleId: createdSaleResult.id,
            method: payment.method,
            amount: payment.amount,
            authCode: payment.authCode,
          ),
        );

        final paymentFailed = await paymentResult.fold(
          (failure) async {
            developer.log(
              'Failed to add payment during finalization',
              error: failure.message,
              name: 'PosBloc',
            );
            return true;
          },
          (_) async => false,
        );

        if (paymentFailed) {
          emit(const PosError(
            message: 'Erro ao registrar pagamentos. Tente novamente.',
          ));
          emit(PosSaleInProgress(
            sale: currentState.sale,
            products: currentState.products,
            discountCode: currentState.discountCode,
          ));
          return;
        }
      }

      // Step 5: Finalize the sale
      final finalizeResult = await finalizeSaleUseCase(
        FinalizeSaleParams(saleId: createdSaleResult.id),
      );

      finalizeResult.fold(
        (failure) {
          developer.log(
            'Failed to finalize sale',
            error: failure.message,
            name: 'PosBloc',
          );
          emit(const PosError(
            message: 'Não foi possível finalizar a venda. Tente novamente.',
          ));
          emit(PosSaleInProgress(
            sale: currentState.sale,
            products: currentState.products,
            discountCode: currentState.discountCode,
          ));
        },
        (finalizedSale) => emit(PosSaleCompleted(finalizedSale)),
      );
    }
  }

  Future<void> _onCancelSale(
    CancelSale event,
    Emitter<PosState> emit,
  ) async {
    final currentState = state;

    if (currentState is PosSaleInProgress) {
      // Just reset to products loaded state (local operation - no API call)
      emit(PosProductsLoaded(currentState.products));
    }
  }

  Future<void> _onReset(
    ResetPos event,
    Emitter<PosState> emit,
  ) async {
    emit(const PosInitial());
  }
}
