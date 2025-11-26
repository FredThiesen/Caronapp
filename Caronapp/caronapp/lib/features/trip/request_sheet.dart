import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/repos/trip_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../core/theme/app_colors.dart';

class RequestSheet extends StatefulWidget {
  final String tripId;
  const RequestSheet({super.key, required this.tripId});

  @override
  State<RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<RequestSheet> {
  final _msgCtrl = TextEditingController();
  bool _loading = false;
  final _repo = TripRepository();

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final riderId = user.uid;
      final riderName =
          user.displayName ?? user.email?.split('@').first ?? 'Convidado';

      // check duplicates
      final has = await _repo.hasPendingRequest(widget.tripId, riderId);
      if (has)
        throw Exception('Você já tem um pedido pendente para esta carona');

      final data = {
        'riderId': riderId,
        'riderName': riderName,
        'message': _msgCtrl.text.trim().isEmpty ? null : _msgCtrl.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _repo.createRequest(widget.tripId, data);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pedido enviado')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar pedido: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicitar vaga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Mensagem (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                _loading
                    ? const SizedBox(
                        height: 44,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                        ),
                        child: const Text('Enviar'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
