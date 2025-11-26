import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// share_plus removed — sharing now uses clipboard + snackbar fallback
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../shared/models/request.dart';
import '../../shared/repos/trip_repository.dart';
import 'request_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/trip.dart';

class TripDetailScreen extends StatelessWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sky,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        title: Text(
          'Detalhes da carona',
          style: TextStyle(color: AppColors.navy),
        ),
      ),
      backgroundColor: AppColors.gray100,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.driverName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trip.whenLabel,
                      style: const TextStyle(color: AppColors.gray700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Origem',
                      style: const TextStyle(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip.origin,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Destino',
                      style: const TextStyle(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip.destination,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (trip.note != null && trip.note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Observação',
                        style: const TextStyle(
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trip.note!,
                        style: const TextStyle(color: AppColors.gray700),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // primary action and share button laid out vertically to avoid Expanded inside unbounded parents
                    // Request button: show state depending on whether current user already requested
                    StreamBuilder<List<RequestModel>>(
                      stream: TripRepository().watchRequests(trip.id),
                      builder: (context, s) {
                        final user = fb_auth.FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // open login sheet
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => const SizedBox.shrink(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                              ),
                              child: const Text('Solicitar vaga'),
                            ),
                          );
                        }

                        // Don't show request button to the trip owner/creator
                        if (user.uid == trip.driverId) {
                          return const SizedBox.shrink();
                        }

                        final reqs = s.data ?? [];
                        final myReqs = reqs
                            .where((r) => r.riderId == user.uid)
                            .toList();
                        if (myReqs.isNotEmpty) {
                          final myReq = myReqs.first;
                          // Already requested — show disabled state with check icon if accepted
                          final accepted = myReq.status == 'accepted';
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: null,
                              icon: Icon(
                                accepted
                                    ? Icons.check_circle
                                    : Icons.hourglass_top,
                                color: Colors.white,
                              ),
                              label: Text(
                                accepted ? 'Confirmado' : 'Solicitado',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gray300,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          );
                        }

                        // No request yet — show button
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // open request sheet
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => RequestSheet(tripId: trip.id),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                            ),
                            child: const Text('Solicitar vaga'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final text =
                              '${trip.driverName} - ${trip.origin} → ${trip.destination} @ ${trip.whenLabel}';
                          await Clipboard.setData(ClipboardData(text: text));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Detalhes copiados para a área de transferência',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.share, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Compartilhar'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // If owner, show requests
          if (currentUser != null && currentUser.uid == trip.driverId)
            StreamBuilder<List<RequestModel>>(
              stream: TripRepository().watchRequests(trip.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const SizedBox();
                if (snap.hasError) return Text('Erro: ${snap.error}');
                final reqs = snap.data ?? [];
                if (reqs.isEmpty) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Pedidos',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...reqs.map(
                      (r) => Card(
                        child: ListTile(
                          title: Text(r.riderName),
                          subtitle: Text(r.message ?? ''),
                          trailing: r.status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await TripRepository().acceptRequest(
                                            trip.id,
                                            r.id,
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao aceitar: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Aceitar'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await TripRepository().rejectRequest(
                                            trip.id,
                                            r.id,
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Erro ao rejeitar: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Rejeitar'),
                                    ),
                                  ],
                                )
                              : Text(r.status),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 12),
          if (trip.passengers.isNotEmpty) ...[
            const Text(
              'Passageiros',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    FieldPath.documentId,
                    whereIn: trip.passengers.take(10).toList(),
                  )
                  .get(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const SizedBox();
                if (snap.hasError) return Text('Erro: \\${snap.error}');
                final docs = snap.data?.docs ?? [];
                return Column(
                  children: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final name = data['name'] as String? ?? 'Usuário';
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(name),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
      bottomNavigationBar:
          (currentUser != null && currentUser.uid != trip.driverId)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.orange,
                  ),
                  child: const Text('Entrar em contato com o motorista'),
                ),
              ),
            )
          : null,
    );
  }
}
