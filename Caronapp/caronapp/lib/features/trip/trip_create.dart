import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
// map/picker removed — no additional imports needed
import '../../shared/repos/trip_repository.dart';
import 'trip_view_model.dart';

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
  final _priceCtrl = TextEditingController();
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
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (time == null) return;
    if (!mounted) return;
    setState(() {
      _when = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit(TripViewModel viewModel) async {
    // reset error state before submit
    if (!_formKey.currentState!.validate() || _when == null) {
      if (_when == null) {
        // set error on viewModel for UI
        viewModel.validate(
          origin: _originCtrl.text,
          destination: _destinationCtrl.text,
          when: _when,
          seats: _seats,
        );
      }
      return;
    }

    double? price;
    if (_priceCtrl.text.trim().isNotEmpty) {
      price = double.tryParse(_priceCtrl.text.trim().replaceAll(',', '.'));
    }

    final ok = await viewModel.createTrip(
      origin: _originCtrl.text,
      destination: _destinationCtrl.text,
      when: _when!,
      seats: _seats,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      price: price,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final err = viewModel.errorMessage ?? 'Erro ao criar carona';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripViewModel(repo: TripRepository()),
      child: Consumer<TripViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.navy),
              title: Text(
                'Criar carona',
                style: const TextStyle(color: AppColors.navy),
              ),
              // make icons and title visible on white background
              foregroundColor: AppColors.navy,
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
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe origem' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _destinationCtrl,
                      decoration: const InputDecoration(labelText: 'Destino'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe destino' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickDateTime,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              side: BorderSide(color: AppColors.gray300),
                            ),
                            child: Text(
                              _when == null
                                  ? 'Escolher data e hora'
                                  : '${_when!.day.toString().padLeft(2, '0')}/${_when!.month.toString().padLeft(2, '0')}/${_when!.year} ${_when!.hour.toString().padLeft(2, '0')}:${_when!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: AppColors.navy),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Seats selector with explanatory label
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vagas (lugares disponíveis)',
                              style: TextStyle(
                                color: AppColors.gray700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButton<int>(
                              value: _seats,
                              items: List.generate(6, (i) => i + 1)
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text('$v'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _seats = v ?? 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Observação (opcional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Preço (ex: 12.50) - opcional',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Spacer(),
                    vm.state == TripState.loading
                        ? const SizedBox(
                            height: 48,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : ElevatedButton(
                            onPressed: () => _submit(vm),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Publicar carona'),
                          ),
                    if (vm.state == TripState.error &&
                        vm.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
