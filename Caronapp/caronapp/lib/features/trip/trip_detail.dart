import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/trip.dart';

class TripDetailScreen extends StatelessWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sky,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        title: Text('Detalhes', style: TextStyle(color: AppColors.navy)),
      ),
      backgroundColor: AppColors.gray100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.navy)),
                    const SizedBox(height: 8),
                    Text(trip.whenLabel, style: const TextStyle(color: AppColors.gray700)),
                    const SizedBox(height: 12),
                    Text('Origem', style: const TextStyle(color: AppColors.gray700, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(trip.origin, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('Destino', style: const TextStyle(color: AppColors.gray700, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(trip.destination, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
                    if (trip.note != null && trip.note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Observação', style: const TextStyle(color: AppColors.gray700, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(trip.note!, style: const TextStyle(color: AppColors.gray700)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: request flow
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
                            child: const Text('Solicitar vaga'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, shape: const CircleBorder(), padding: const EdgeInsets.all(14)),
                          child: const Icon(Icons.share, color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
