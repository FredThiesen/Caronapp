import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/repos/trip_repository.dart';

enum TripState { idle, loading, success, error }

class TripViewModel extends ChangeNotifier {
  final TripRepository _repo;

  TripState _state = TripState.idle;
  String? _errorMessage;

  TripViewModel({TripRepository? repo}) : _repo = repo ?? TripRepository();

  TripState get state => _state;
  String? get errorMessage => _errorMessage;

  void _setState(TripState s, {String? error}) {
    _state = s;
    _errorMessage = error;
    notifyListeners();
  }

  bool validate({
    required String origin,
    required String destination,
    DateTime? when,
    required int seats,
  }) {
    if (origin.trim().isEmpty) {
      _setState(TripState.error, error: 'Informe a origem');
      return false;
    }
    if (destination.trim().isEmpty) {
      _setState(TripState.error, error: 'Informe o destino');
      return false;
    }
    if (when == null) {
      _setState(TripState.error, error: 'Escolha data e hora');
      return false;
    }
    if (when.isBefore(DateTime.now())) {
      _setState(TripState.error, error: 'Data/hora no passado');
      return false;
    }
    if (seats <= 0) {
      _setState(TripState.error, error: 'Informe pelo menos 1 vaga');
      return false;
    }
    return true;
  }

  Future<bool> createTrip({
    required String origin,
    required String destination,
    required DateTime when,
    required int seats,
    String? note,
    double? price,
    GeoPoint? originLocation,
  }) async {
    _setState(TripState.loading);
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setState(TripState.error, error: 'Usuário não autenticado');
        return false;
      }

      final driverId = user.uid;
      final driverName =
          user.displayName ?? user.email?.split('@').first ?? 'Motorista';

      await _repo.createTripData({
        'driverId': driverId,
        'driverName': driverName,
        'driverAvatarUrl': null,
        'origin': origin.trim(),
        'destination': destination.trim(),
        'whenLabel':
            '${when.day.toString().padLeft(2, '0')}/${when.month.toString().padLeft(2, '0')} ${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}',
        'when': Timestamp.fromDate(when),
        'seats': seats,
        'price': price,
        'passengers': <String>[],
        'originLocation': originLocation,
        'note': note?.trim(),
        'active': true,
      });

      _setState(TripState.success);
      return true;
    } catch (e) {
      _setState(TripState.error, error: e.toString());
      return false;
    }
  }
}
