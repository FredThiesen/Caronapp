import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/user.dart';
import '../../shared/models/trip.dart';
import '../../shared/mocks/mock_trips.dart';
import '../../shared/widgets/trip_card.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      body: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            color: AppColors.amber,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Olá, ${user.name}!',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pronto para compartilhar uma carona hoje?',
                      style: TextStyle(
                        color: AppColors.navy.withOpacity(0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: mockTrips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = mockTrips[index];
                return TripCard(
                  driverName: t.driverName,
                  avatarUrl: t.avatarUrl,
                  origin: t.origin,
                  destination: t.destination,
                  whenLabel: t.whenLabel,
                  seats: t.seats,
                  note: t.note,
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
