import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import '../bloc/pos_state.dart';
import '../widgets/product_grid.dart';
import '../widgets/shopping_cart_panel.dart';
import '../widgets/payment_dialog.dart';
import '../widgets/discount_dialog.dart';
import '../widgets/sale_complete_dialog.dart';

/// POS (Point of Sale) main page
class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ponto de Venda'),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<PosBloc, PosState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message, products, sale) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message), backgroundColor: Colors.red),
              );
            },
            saleCompleted: (sale) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => SaleCompleteDialog(
                  sale: sale,
                  onNewSale: () {
                    Navigator.of(dialogContext).pop();
                    context.read<PosBloc>().add(const CreateSale());
                  },
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                    context.read<PosBloc>().add(const LoadProducts());
                  },
                ),
              );
            },
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => _buildInitialView(context),
            loadingProducts: () =>
                const Center(child: CircularProgressIndicator()),
            productsLoaded: (products) => SingleChildScrollView(
              child: Column(
                children: [
                  _buildProductsView(
                    context,
                    products: products,
                    hasActiveSale: false,
                  ),
                  _buildEmptyCartPanel(context, Theme.of(context)),
                ],
              ),
            ),
            saleInProgress: (sale, products, discountCode) => SingleChildScrollView(
              child: Column(
                children: [
                  _buildProductsView(
                    context,
                    products: products,
                    hasActiveSale: true,
                    saleId: sale.id,
                  ),
                  ShoppingCartPanel(
                    sale: sale,
                    discountCode: discountCode,
                    onApplyDiscount: () => _showDiscountDialog(context),
                    onAddPayment: () => _showPaymentDialog(context, sale),
                    onFinalizeSale: () {
                      context.read<PosBloc>().add(const FinalizeSale());
                    },
                    onCancelSale: () {
                      _showCancelConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
            processingPayment: (sale, products) => SingleChildScrollView(
              child: Column(
                children: [
                  _buildProductsView(
                    context,
                    products: products,
                    hasActiveSale: true,
                    saleId: sale.id,
                  ),
                  ShoppingCartPanel(
                    sale: sale,
                    isProcessing: true,
                    onApplyDiscount: () {},
                    onAddPayment: () {},
                    onFinalizeSale: () {},
                    onCancelSale: () {},
                  ),
                ],
              ),
            ),
            saleCompleted: (sale) =>
                const Center(child: CircularProgressIndicator()),
            error: (message, products, sale) {
              if (products != null && sale != null) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProductsView(
                        context,
                        products: products,
                        hasActiveSale: true,
                        saleId: sale.id,
                      ),
                      ShoppingCartPanel(
                        sale: sale,
                        onApplyDiscount: () => _showDiscountDialog(context),
                        onAddPayment: () => _showPaymentDialog(context, sale),
                        onFinalizeSale: () {
                          context.read<PosBloc>().add(const FinalizeSale());
                        },
                        onCancelSale: () {
                          _showCancelConfirmation(context);
                        },
                      ),
                    ],
                  ),
                );
              } else if (products != null) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProductsView(
                        context,
                        products: products,
                        hasActiveSale: false,
                      ),
                      _buildEmptyCartPanel(context, Theme.of(context)),
                    ],
                  ),
                );
              }
              return _buildInitialView(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PosBloc>().add(const LoadProducts());
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar POS'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsView(
    BuildContext context, {
    required dynamic products,
    required bool hasActiveSale,
    String? saleId,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: hasActiveSale && saleId != null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.green.shade900,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Venda Ativa',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '#${saleId.substring(0, 8)}',
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<PosBloc>().add(const CreateSale());
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Nova Venda'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        ProductGrid(products: products),
      ],
    );
  }

  void _showDiscountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DiscountDialog(
        onApply: (code) {
          Navigator.of(dialogContext).pop();
          context.read<PosBloc>().add(ApplyDiscount(code: code));
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, dynamic sale) {
    showDialog(
      context: context,
      builder: (dialogContext) => PaymentDialog(
        remainingAmount: sale.grandTotal - sale.totalPaid,
        onAddPayment: (method, amount, authCode) {
          Navigator.of(dialogContext).pop();
          context.read<PosBloc>().add(
            AddPayment(method: method, amount: amount, authCode: authCode),
          );
        },
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Venda'),
        content: const Text(
          'Tem certeza que deseja cancelar esta venda? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PosBloc>().add(const CancelSale());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar Venda'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartPanel(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Carrinho',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text('0 itens', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          // Empty state
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sem venda ativa',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clique em "Nova Venda" para começar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
