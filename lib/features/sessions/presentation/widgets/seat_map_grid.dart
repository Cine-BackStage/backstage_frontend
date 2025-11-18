import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../domain/entities/seat.dart';

/// Visual seat map grid showing seat layout with status indicators
class SeatMapGrid extends StatelessWidget {
  final List<Seat> seats;
  final List<Seat> selectedSeats;
  final Function(Seat seat)? onSeatTap;
  final bool readOnly;
  final int rows;
  final int columns;

  const SeatMapGrid({
    super.key,
    required this.seats,
    required this.selectedSeats,
    this.onSeatTap,
    this.readOnly = false,
    this.rows = 10,
    this.columns = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Screen indicator
        _buildScreenIndicator(),
        const SizedBox(height: 16),

        // Legend
        _buildLegend(),
        const SizedBox(height: 12),

        // Seat grid with zoom
        Expanded(
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 3.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: _buildSeatGrid(constraints.maxWidth),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScreenIndicator() {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem('Disponível', AppColors.success),
          _buildLegendItem('Reservado', Colors.grey[600]!),
          _buildLegendItem('Selecionado', AppColors.primary),
          _buildLegendItem('Acessível', Colors.purple[400]!),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatGrid(double availableWidth) {
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

    // Calculate max seats per row to determine seat size
    int maxSeatsPerRow = 0;
    for (final rowSeats in seatsByRow.values) {
      if (rowSeats.length > maxSeatsPerRow) {
        maxSeatsPerRow = rowSeats.length;
      }
    }

    // Calculate seat size based on available width
    // Formula: (availableWidth - labels(60) - padding(16) - aisle(16)) / maxSeats
    final labelWidth = 30.0;
    final totalLabelWidth = labelWidth * 2; // left + right labels
    final aisleWidth = 16.0;
    final horizontalPadding = 16.0;
    final seatPadding = 1.5 * 2; // padding on each side of seat

    final availableForSeats = availableWidth - totalLabelWidth - aisleWidth - horizontalPadding;
    final maxSeatSize = 28.0; // Maximum seat size
    final minSeatSize = 20.0; // Minimum seat size

    double calculatedSize = (availableForSeats / maxSeatsPerRow) - seatPadding;
    final seatSize = calculatedSize.clamp(minSeatSize, maxSeatSize);

    return Column(
      children: sortedRows.map((row) {
        final rowSeats = seatsByRow[row]!;
        // Sort seats by column
        rowSeats.sort((a, b) => a.column.compareTo(b.column));

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Row label
              SizedBox(
                width: labelWidth,
                child: Text(
                  row,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),

              // Seats
              ...rowSeats.map((seat) {
                // Add aisle spacing (split in middle)
                final addAisle = seat.column == (maxSeatsPerRow / 2).floor();
                return Row(
                  children: [
                    if (addAisle) SizedBox(width: aisleWidth),
                    _buildSeatWidget(seat, seatSize),
                  ],
                );
              }),

              const SizedBox(width: 8),
              // Row label (right side)
              SizedBox(
                width: labelWidth,
                child: Text(
                  row,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeatWidget(Seat seat, double size) {
    final isSelected = selectedSeats.any((s) => s.id == seat.id);
    final isReserved = seat.isReserved || seat.isSold;
    final isAvailable = seat.isAvailable && !isReserved;
    final canTap = !readOnly && (isAvailable || isSelected);

    Color backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (isSelected) {
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
    } else if (isReserved) {
      backgroundColor = Colors.grey[700]!;
      borderColor = Colors.grey[600];
    } else if (seat.isAccessible) {
      backgroundColor = Colors.purple[400]!;
      borderColor = Colors.purple[300];
      icon = Icons.accessible;
    } else if (isAvailable) {
      backgroundColor = AppColors.success;
      borderColor = AppColors.success.withValues(alpha: 0.7);
    } else {
      backgroundColor = Colors.grey[800]!;
      borderColor = Colors.grey[700];
    }

    final fontSize = (size * 0.35).clamp(8.0, 11.0);
    final iconSize = (size * 0.45).clamp(10.0, 14.0);

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: InkWell(
        onTap: canTap && onSeatTap != null ? () => onSeatTap!(seat) : null,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor ?? backgroundColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: iconSize, color: Colors.white)
                : Text(
                    seat.column.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
