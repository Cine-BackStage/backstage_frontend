import 'package:flutter/material.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../shared/utils/extensions/num_extensions.dart';
import '../../../../shared/utils/formatters/date_formatter.dart';
import '../../domain/entities/session.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: session.isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie title and format
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.movieTitle,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      session.format,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Time and room
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.time(session.startTime),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.meeting_room,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.roomName,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Language and subtitles
              Row(
                children: [
                  Icon(
                    Icons.language,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.language,
                    style: AppTextStyles.bodySmall,
                  ),
                  if (session.subtitles != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• Legendas: ${session.subtitles}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Availability and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Availability indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: session.isSoldOut
                              ? AppColors.error
                              : session.availableSeats < 10
                                  ? Colors.orange
                                  : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.isSoldOut
                            ? 'Esgotado'
                            : '${session.availableSeats} assentos',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: session.isSoldOut
                              ? AppColors.error
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  // Price
                  Text(
                    session.basePrice.toCurrency(),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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
