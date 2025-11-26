import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/user.dart';
import '../../shared/models/trip.dart';
import '../../shared/widgets/trip_card.dart';
import '../../shared/repos/trip_repository.dart';
import '../trip/trip_create.dart';
import '../trip/trip_detail.dart';
import '../../services/auth_service.dart';
import '../intro/intro_screen.dart';

final _tripRepo = TripRepository();

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TripCreateScreen()));
        },
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
                // keep a small bottom padding so the SafeArea + fixed height don't overflow
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  // center vertically to avoid overflow when system paddings change
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Olá, ${user.name}!',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
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
                    // Logout button
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: IconButton(
                        tooltip: 'Sair',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: const Icon(Icons.logout, color: AppColors.navy),
                        onPressed: () async {
                          final auth = AuthService();
                          await auth.signOut();
                          if (!Navigator.of(context).mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const IntroScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Trip>>(
              stream: _tripRepo.watchUpcomingTrips(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: \\${snapshot.error}'));
                }
                final trips = snapshot.data ?? [];
                if (trips.isEmpty) {
                  return const Center(child: Text('Nenhuma carona disponível'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: trips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = trips[index];
                    return TripCard(
                      driverName: t.driverName,
                      avatarUrl: t.driverAvatarUrl,
                      origin: t.origin,
                      destination: t.destination,
                      whenLabel: t.whenLabel,
                      seats: t.seats,
                      price: t.price,
                      note: t.note,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TripDetailScreen(trip: t),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
