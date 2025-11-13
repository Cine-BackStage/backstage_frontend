import 'package:flutter/material.dart';
import '../../domain/entities/sale.dart';

/// Dialog shown when sale is successfully completed
class SaleCompleteDialog extends StatelessWidget {
  final Sale sale;
  final VoidCallback onNewSale;
  final VoidCallback onClose;

  const SaleCompleteDialog({
    super.key,
    required this.sale,
    required this.onNewSale,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Text('Venda Finalizada!'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sale ID
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'ID da Venda',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${sale.id}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sale summary
            _buildSummaryRow('Total de Itens', '${sale.items.length}'),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Subtotal',
              'R\$ ${sale.subtotal.toStringAsFixed(2)}',
            ),
            if (sale.discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Desconto',
                '-R\$ ${sale.discountAmount.toStringAsFixed(2)}',
                valueColor: Colors.green,
              ),
            ],
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              'R\$ ${sale.grandTotal.toStringAsFixed(2)}',
              titleStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              valueStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Payments
            if (sale.payments.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Pagamentos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...sale.payments.map((payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getPaymentIcon(payment.method),
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(payment.method.displayName),
                          ],
                        ),
                        Text(
                          'R\$ ${payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Fechar'),
        ),
        FilledButton.icon(
          onPressed: onNewSale,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Nova Venda'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String title,
    String value, {
    TextStyle? titleStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: titleStyle),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(dynamic method) {
    final methodName = method.value.toString().toLowerCase();
    switch (methodName) {
      case 'cash':
        return Icons.attach_money;
      case 'card':
        return Icons.credit_card;
      case 'pix':
        return Icons.qr_code;
      default:
        return Icons.payment;
    }
  }
}
