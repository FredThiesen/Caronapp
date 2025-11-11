import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/repos/trip_repository.dart';

class TripCreateScreen extends StatefulWidget {
  const TripCreateScreen({super.key});

  @override
  State<TripCreateScreen> createState() => _TripCreateScreenState();
}

class _TripCreateScreenState extends State<TripCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime? _when;
  int _seats = 1;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    // Widget may be unmounted while waiting for the next dialog — check mounted
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (time == null) return;
    if (!mounted) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    _submitInternal();
  }

  Future<void> _submitInternal() async {
    if (!_formKey.currentState!.validate() || _when == null) return;
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      final driverId = user?.uid ?? 'unknown';
      final driverName = user?.displayName ?? user?.email?.split('@').first ?? 'Motorista';
      final data = {
        'driverId': driverId,
        'driverName': driverName,
        'driverAvatarUrl': null,
        'origin': _originCtrl.text.trim(),
        'destination': _destinationCtrl.text.trim(),
        'whenLabel': '${_when!.day.toString().padLeft(2, '0')}/${_when!.month.toString().padLeft(2, '0')} ${_when!.hour.toString().padLeft(2, '0')}:${_when!.minute.toString().padLeft(2, '0')}',
        'when': Timestamp.fromDate(_when!),
        'seats': _seats,
        'note': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        'active': true,
      };
      final repo = TripRepository();
      await repo.createTripData(data);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar carona: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sky,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        title: Text('Criar carona', style: const TextStyle(color: AppColors.navy)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _originCtrl,
                decoration: const InputDecoration(labelText: 'Origem'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe origem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinationCtrl,
                decoration: const InputDecoration(labelText: 'Destino'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe destino' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDateTime,
                      child: Text(_when == null
                          ? 'Escolher data e hora'
                          : '${_when!.day.toString().padLeft(2, '0')}/${_when!.month.toString().padLeft(2, '0')}/${_when!.year} ${_when!.hour.toString().padLeft(2, '0')}:${_when!.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _seats,
                    items: List.generate(6, (i) => i + 1).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                    onChanged: (v) => setState(() => _seats = v ?? 1),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Observação (opcional)'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, minimumSize: const Size.fromHeight(48)),
                child: const Text('Publicar carona'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
