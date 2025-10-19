import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../indicators/status_badge.dart';

/// Session card for Backstage Cinema
class SessionCard extends StatelessWidget {
  final String movieTitle;
  final String roomName;
  final String time;
  final StatusBadgeType status;
  final String statusLabel;
  final int? occupancy;
  final int? capacity;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.movieTitle,
    required this.roomName,
    required this.time,
    required this.status,
    required this.statusLabel,
    this.occupancy,
    this.capacity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasOccupancy = occupancy != null && capacity != null;
    final occupancyPercentage =
        hasOccupancy ? (occupancy! / capacity!).clamp(0.0, 1.0) : 0.0;

    return Card(
      color: AppColors.surface,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      movieTitle,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing8),
                  StatusBadge(
                    label: statusLabel,
                    type: status,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing12),
              Row(
                children: [
                  Icon(
                    Icons.meeting_room,
                    size: AppDimensions.iconSmall,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    roomName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing16),
                  Icon(
                    Icons.access_time,
                    size: AppDimensions.iconSmall,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppDimensions.spacing4),
                  Text(
                    time,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (hasOccupancy) ...[
                const SizedBox(height: AppDimensions.spacing12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSmall,
                        ),
                        child: LinearProgressIndicator(
                          value: occupancyPercentage,
                          backgroundColor: AppColors.grayCurtain,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            occupancyPercentage > 0.8
                                ? AppColors.alertCritical
                                : occupancyPercentage > 0.5
                                    ? AppColors.alertWarning
                                    : AppColors.successGreen,
                          ),
                          minHeight: AppDimensions.progressBarHeight,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacing8),
                    Text(
                      '$occupancy/$capacity',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
