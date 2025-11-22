import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/payment.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';

/// Shopping cart panel showing sale items and totals
class ShoppingCartPanel extends StatelessWidget {
  final Sale sale;
  final String discountCode;
  final bool isProcessing;
  final VoidCallback onApplyDiscount;
  final VoidCallback onAddPayment;
  final VoidCallback onFinalizeSale;
  final VoidCallback onCancelSale;

  const ShoppingCartPanel({
    super.key,
    required this.sale,
    this.discountCode = '',
    this.isProcessing = false,
    required this.onApplyDiscount,
    required this.onAddPayment,
    required this.onFinalizeSale,
    required this.onCancelSale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('shoppingCartPanel'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Carrinho',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${sale.items.length} itens',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Items list
          SizedBox(
            height: 200,
            child: sale.items.isEmpty
                ? Center(
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
                          'Carrinho vazio',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sale.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = sale.items[index];
                      return ListTile(
                        key: Key('cartItem_$index'),
                        title: Text(
                          item.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'R\$ ${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              key: Key('removeCartItem_$index'),
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: isProcessing
                                  ? null
                                  : () {
                                      context.read<PosBloc>().add(
                                            RemoveItemFromCart(itemId: item.id),
                                          );
                                    },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Totals and actions (scrollable)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Discount section
                if (discountCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.green.shade900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Desconto: $discountCode',
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '-R\$ ${sale.discountAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Subtotal
                _buildTotalRow(
                  'Subtotal',
                  sale.subtotal,
                  theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),

                // Discount
                if (sale.discountAmount > 0)
                  _buildTotalRow(
                    'Desconto',
                    -sale.discountAmount,
                    theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                if (sale.discountAmount > 0) const SizedBox(height: 8),

                const Divider(),
                const SizedBox(height: 8),

                // Grand total
                Row(
                  key: const Key('totalAmountText'),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    )),
                    Text(
                      'R\$ ${sale.grandTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Paid amount
                if (sale.totalPaid > 0) ...[
                  Row(
                    key: const Key('paidAmountText'),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pago', style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.green,
                      )),
                      Text(
                        'R\$ ${sale.totalPaid.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Remaining amount
                if (sale.totalPaid > 0) ...[
                  Row(
                    key: const Key('remainingAmountText'),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Restante', style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: sale.isPaymentComplete
                            ? Colors.green
                            : Colors.orange,
                      )),
                      Text(
                        'R\$ ${(sale.grandTotal - sale.totalPaid).toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: sale.isPaymentComplete
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Payments list
                if (sale.payments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Pagamentos:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...sale.payments.map((payment) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getPaymentIcon(payment.method),
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                payment.method.displayName,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              'R\$ ${payment.amount.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!isProcessing)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  context.read<PosBloc>().add(
                                        RemovePayment(paymentId: payment.id),
                                      );
                                },
                              ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                // Action buttons
                if (!isProcessing) ...[
                  // Discount button
                  if (discountCode.isEmpty && sale.items.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('applyDiscountButton'),
                        onPressed: onApplyDiscount,
                        icon: const Icon(Icons.local_offer),
                        label: const Text('Aplicar Desconto'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.orange.shade700, width: 2),
                          foregroundColor: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  if (discountCode.isEmpty && sale.items.isNotEmpty)
                    const SizedBox(height: 8),

                  // Payment button
                  if (sale.items.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('addPaymentButton'),
                        onPressed: onAddPayment,
                        icon: const Icon(Icons.payment),
                        label: Text(
                          sale.totalPaid > 0
                              ? 'Adicionar Pagamento'
                              : 'Registrar Pagamento',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (sale.items.isNotEmpty) const SizedBox(height: 8),

                  // Finalize button
                  if (sale.isPaymentComplete && sale.items.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('finalizeSaleButton'),
                        onPressed: onFinalizeSale,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Finalizar Venda'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (sale.isPaymentComplete && sale.items.isNotEmpty)
                    const SizedBox(height: 8),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('cancelSaleButton'),
                      onPressed: onCancelSale,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar Venda'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red, width: 2),
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],

                if (isProcessing)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.attach_money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.pix:
        return Icons.qr_code;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  Widget _buildTotalRow(String label, double value, TextStyle? style) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          'R\$ ${value.toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }
}
