import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import '../widgets/inventory_product_list.dart';
import '../widgets/inventory_search_bar.dart';
import 'create_product_page.dart';

/// Inventory management page
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<InventoryBloc>()..add(const LoadInventoryRequested()),
      child: const InventoryView(),
    );
  }
}

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateProductPage(),
                ),
              );

              // Refresh list if product was created
              if (result == true && context.mounted) {
                context.read<InventoryBloc>().add(const LoadInventoryRequested());
              }
            },
            tooltip: 'Adicionar Produto',
          ),
        ],
      ),
      body: Column(
        children: [
          const InventorySearchBar(),
          Expanded(
            child: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                return state.when(
                  initial: () =>
                      const Center(child: Text('Carregando inventário...')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  loaded: (products) {
                    if (products.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum produto encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return InventoryProductList(products: products);
                  },
                  productDetails: (product, adjustments) {
                    // This state is handled in a separate details page
                    return const SizedBox.shrink();
                  },
                  error: (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<InventoryBloc>().add(
                              const LoadInventoryRequested(),
                            );
                          },
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
