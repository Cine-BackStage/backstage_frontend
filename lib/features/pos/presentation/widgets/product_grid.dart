import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';

/// Grid of products for sale
class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final availableProducts =
        products.where((product) => product.isAvailable).toList();

    if (availableProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum produto disponível',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      key: const Key('productGrid'),
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: availableProducts.length,
      itemBuilder: (context, index) {
        final product = availableProducts[index];
        return _ProductCard(product: product);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveSale = context.select<PosBloc, bool>(
      (bloc) => bloc.state.maybeWhen(
            saleInProgress: (_, __, ___) => true,
            orElse: () => false,
          ),
    );

    // Calculate available stock (total - already in cart)
    final quantityInCart = context.select<PosBloc, int>(
      (bloc) => bloc.state.maybeWhen(
            saleInProgress: (sale, _, __) => sale.items
                .where((item) => item.sku == product.sku)
                .fold<int>(0, (sum, item) => sum + item.quantity),
            orElse: () => 0,
          ),
    );

    final availableStock = product.qtyOnHand - quantityInCart;

    return Card(
      key: Key('product_${product.sku}'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasActiveSale
            ? () => _addToCart(context)
            : () => _showMessage(context, 'Crie uma venda primeiro'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Product name
              Text(
                product.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Price
              Text(
                'R\$ ${product.unitPrice.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Category and stock
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      product.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: availableStock > 10
                          ? Colors.green.shade100
                          : availableStock > 0
                              ? Colors.orange.shade100
                              : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$availableStock',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: availableStock > 10
                            ? Colors.green.shade900
                            : availableStock > 0
                                ? Colors.orange.shade900
                                : Colors.red.shade900,
                        fontWeight: FontWeight.bold,
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

  void _addToCart(BuildContext context) {
    context.read<PosBloc>().add(
          AddItemToCart(
            productSku: product.sku,
            description: product.name,
            unitPrice: product.unitPrice,
            quantity: 1,
          ),
        );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
