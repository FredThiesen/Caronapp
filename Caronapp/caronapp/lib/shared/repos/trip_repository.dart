import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class TripRepository {
  final CollectionReference _trips = FirebaseFirestore.instance.collection('trips');

  Stream<List<Trip>> watchUpcomingTrips() {
    return _trips
        .where('active', isEqualTo: true)
        .orderBy('when')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Trip.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> createTrip(Trip trip) async {
    await _trips.add(trip.toMap());
  }

  Future<void> createTripData(Map<String, dynamic> data) async {
    await _trips.add(data);
  }

  Future<Trip?> getTrip(String id) async {
    final doc = await _trips.doc(id).get();
    if (!doc.exists) return null;
    return Trip.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
  }
}
