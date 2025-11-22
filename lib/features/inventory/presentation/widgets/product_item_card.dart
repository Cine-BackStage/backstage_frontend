import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../pos/domain/entities/product.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';

/// Product item card widget
class ProductItemCard extends StatelessWidget {
  final Product product;

  const ProductItemCard({
    super.key,
    required this.product,
  });

  Color _getStockStatusColor() {
    if (product.isExpired) {
      return Colors.red;
    } else if (product.isExpiringSoon) {
      return Colors.deepOrange;
    } else if (product.qtyOnHand <= 0) {
      return Colors.red;
    } else if (product.isLowStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStockStatusIcon() {
    if (product.isExpired || product.qtyOnHand <= 0) {
      return Icons.cancel;
    } else if (product.isExpiringSoon || product.isLowStock) {
      return Icons.warning_amber;
    } else {
      return Icons.check_circle;
    }
  }

  String _getStockStatusLabel() {
    if (product.isExpired) {
      return 'Vencido';
    } else if (product.isExpiringSoon) {
      return 'Vencendo';
    } else if (product.qtyOnHand <= 0) {
      return 'Sem estoque';
    } else if (product.isLowStock) {
      return 'Estoque baixo';
    } else {
      return 'Em estoque';
    }
  }

  void _showRestockDialog(BuildContext context) {
    final quantityController = TextEditingController(text: product.qtyOnHand.toString());
    final priceController = TextEditingController(text: product.unitPrice.toStringAsFixed(2));
    DateTime? selectedExpiryDate = product.expiryDate;

    // Capture the BLoC from parent context before dialog
    final inventoryBloc = context.read<InventoryBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) => AlertDialog(
          key: const Key('adjustStockDialog'),
          title: const Text('Reestoque e Atualização'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('adjustQuantityField'),
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nova Quantidade',
                    hintText: 'Ex: 50',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Novo Preço',
                    hintText: 'Ex: 15.50',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (product.category == 'Snacks' || product.expiryDate != null) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedExpiryDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedExpiryDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Data de Validade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: selectedExpiryDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    selectedExpiryDate = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      child: Text(
                        selectedExpiryDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedExpiryDate!)
                            : 'Selecionar data',
                        style: TextStyle(
                          color: selectedExpiryDate != null ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              key: const Key('confirmAdjustmentButton'),
              onPressed: () {
                final newQty = int.tryParse(quantityController.text);
                final newPrice = double.tryParse(priceController.text);

                if (newQty != null && newPrice != null) {
                  // Calculate adjustment
                  final adjustment = newQty - product.qtyOnHand;

                  if (adjustment != 0) {
                    inventoryBloc.add(
                      AdjustStockRequested(
                        sku: product.sku,
                        quantity: adjustment,
                        reason: adjustment > 0 ? 'Reestoque' : 'Ajuste de estoque',
                        notes: 'Quantidade ajustada de ${product.qtyOnHand} para $newQty',
                      ),
                    );
                  }

                  // Update price if changed
                  if (newPrice != product.unitPrice) {
                    inventoryBloc.add(
                      UpdateProductRequested(
                        sku: product.sku,
                        unitPrice: newPrice,
                      ),
                    );
                  }

                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('deleteProductDialog'),
        title: const Text('Excluir Produto'),
        content: Text(
          'Tem certeza que deseja excluir "${product.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('confirmDeleteProductButton'),
            onPressed: () {
              context.read<InventoryBloc>().add(
                    ToggleProductStatusRequested(
                      sku: product.sku,
                      isActive: false,
                    ),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Card(
      key: Key('product_${product.sku}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${product.sku}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStockStatusColor().withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStockStatusColor(),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStockStatusIcon(),
                          size: 16,
                          color: _getStockStatusColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStockStatusLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStockStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoria',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preço Unitário',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormat.format(product.unitPrice),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantidade',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${product.qtyOnHand}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getStockStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (product.barcode != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Código de Barras: ${product.barcode}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (product.expiryDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      product.isExpired
                          ? Icons.error
                          : product.isExpiringSoon
                              ? Icons.warning_amber
                              : Icons.calendar_today,
                      size: 16,
                      color: product.isExpired
                          ? Colors.red
                          : product.isExpiringSoon
                              ? Colors.deepOrange
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Validade: ${DateFormat('dd/MM/yyyy').format(product.expiryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: product.isExpired
                            ? Colors.red
                            : product.isExpiringSoon
                                ? Colors.deepOrange
                                : Colors.grey[600],
                        fontWeight: (product.isExpired || product.isExpiringSoon)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      key: Key('adjustStockButton_${product.sku}'),
                      onPressed: () => _showRestockDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reestoque',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      key: Key('deleteProductButton_${product.sku}'),
                      onPressed: () => _showDeleteDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
