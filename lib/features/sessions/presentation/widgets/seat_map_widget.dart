import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../domain/entities/seat.dart';

class SeatMapWidget extends StatelessWidget {
  final List<Seat> seats;
  final List<Seat> selectedSeats;
  final Function(Seat) onSeatTap;

  const SeatMapWidget({
    super.key,
    required this.seats,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group seats by row
    final Map<String, List<Seat>> seatsByRow = {};
    for (final seat in seats) {
      if (!seatsByRow.containsKey(seat.row)) {
        seatsByRow[seat.row] = [];
      }
      seatsByRow[seat.row]!.add(seat);
    }

    // Sort rows alphabetically
    final sortedRows = seatsByRow.keys.toList()..sort();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Screen indicator
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'TELA',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Seat map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final row in sortedRows)
                  _buildRow(row, seatsByRow[row]!),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Legend
          _buildLegend(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRow(String rowLabel, List<Seat> rowSeats) {
    // Sort seats by column
    rowSeats.sort((a, b) => a.column.compareTo(b.column));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row label
          SizedBox(
            width: 24,
            child: Text(
              rowLabel,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),

          // Seats
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: rowSeats.map((seat) => _buildSeat(seat)).toList(),
            ),
          ),

          const SizedBox(width: 32), // Space for symmetry
        ],
      ),
    );
  }

  Widget _buildSeat(Seat seat) {
    final isSelected = selectedSeats.any((s) => s.id == seat.id);
    final isAvailable = seat.isAvailable;
    final isSold = seat.isSold;
    final isVIP = seat.type == 'VIP';

    Color backgroundColor;
    Color borderColor;
    IconData? icon;

    if (isSelected) {
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
    } else if (isSold) {
      backgroundColor = Colors.grey[300]!;
      borderColor = Colors.grey[400]!;
    } else if (isAvailable) {
      backgroundColor = Colors.white;
      borderColor = isVIP ? Colors.amber : Colors.grey[300]!;
      if (isVIP) {
        icon = Icons.star;
      }
    } else {
      backgroundColor = Colors.grey[200]!;
      borderColor = Colors.grey[300]!;
    }

    return InkWell(
      onTap: (isAvailable || isSelected) ? () => onSeatTap(seat) : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.amber,
                )
              : Text(
                  seat.column.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isSold
                            ? Colors.grey[600]
                            : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          _buildLegendItem(
            color: Colors.white,
            borderColor: Colors.grey[300]!,
            label: 'Disponível',
          ),
          _buildLegendItem(
            color: AppColors.primary,
            borderColor: AppColors.primary,
            label: 'Selecionado',
          ),
          _buildLegendItem(
            color: Colors.grey[300]!,
            borderColor: Colors.grey[400]!,
            label: 'Ocupado',
          ),
          _buildLegendItem(
            color: Colors.white,
            borderColor: Colors.amber,
            label: 'VIP',
            icon: Icons.star,
            iconColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required Color borderColor,
    required String label,
    IconData? icon,
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: icon != null
              ? Icon(icon, size: 12, color: iconColor)
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
