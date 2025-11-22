import 'package:flutter/material.dart';
import '../../../pos/domain/entities/product.dart';
import 'product_item_card.dart';

/// Inventory product list widget
class InventoryProductList extends StatelessWidget {
  final List<Product> products;

  const InventoryProductList({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const Key('productList'),
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductItemCard(product: product);
      },
    );
  }
}
