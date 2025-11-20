import 'dart:async';
import 'package:backstage_frontend/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';

/// Inventory search bar widget
class InventorySearchBar extends StatefulWidget {
  const InventorySearchBar({super.key});

  @override
  State<InventorySearchBar> createState() => _InventorySearchBarState();
}

class _InventorySearchBarState extends State<InventorySearchBar> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showLowStockFilter = false;
  bool _showExpiringSoonFilter = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounce?.cancel();

    // If empty, clear immediately
    if (value.isEmpty) {
      context.read<InventoryBloc>().add(const ClearFiltersRequested());
      return;
    }

    // Wait 500ms after user stops typing before searching
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<InventoryBloc>().add(SearchProductsRequested(value));
    });
  }

  void _toggleLowStockFilter() {
    setState(() {
      _showLowStockFilter = !_showLowStockFilter;
      if (_showLowStockFilter) {
        _showExpiringSoonFilter = false;
      }
    });

    if (_showLowStockFilter) {
      _searchController.clear();
      context.read<InventoryBloc>().add(const FilterLowStockRequested());
    } else {
      context.read<InventoryBloc>().add(const LoadInventoryRequested());
    }
  }

  void _toggleExpiringSoonFilter() {
    setState(() {
      _showExpiringSoonFilter = !_showExpiringSoonFilter;
      if (_showExpiringSoonFilter) {
        _showLowStockFilter = false;
      }
    });

    if (_showExpiringSoonFilter) {
      _searchController.clear();
      context.read<InventoryBloc>().add(const FilterExpiringSoonRequested());
    } else {
      context.read<InventoryBloc>().add(const LoadInventoryRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        _focusNode.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLowStockFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _showLowStockFilter
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Estoque Baixo',
                      style: TextStyle(
                        color: _showLowStockFilter
                            ? Colors.white
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _toggleExpiringSoonFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _showExpiringSoonFilter
                          ? Colors.deepOrange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.deepOrange,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Próximo da Validade',
                      style: TextStyle(
                        color: _showExpiringSoonFilter
                            ? Colors.white
                            : Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
