import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TripCard extends StatelessWidget {
  final String driverName;
  final String? avatarUrl;
  final String origin;
  final String destination;
  final String whenLabel;
  final int seats;
  final String? note;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.driverName,
    this.avatarUrl,
    required this.origin,
    required this.destination,
    required this.whenLabel,
    required this.seats,
    this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.sky,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            driverName.isNotEmpty ? driverName[0] : '',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          whenLabel,
                          style: const TextStyle(
                            color: AppColors.gray700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$seats vagas',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Route
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _TripPoint(color: AppColors.blue),
                      Container(width: 2, height: 18, color: AppColors.gray300),
                      _TripPoint(color: AppColors.orange),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          origin,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          destination,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (note != null && note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray700,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TripPoint extends StatelessWidget {
  final Color color;
  const _TripPoint({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
