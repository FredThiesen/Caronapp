import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';
import '../models/request.dart';

class TripRepository {
  final CollectionReference _trips = FirebaseFirestore.instance.collection(
    'trips',
  );

  Stream<List<Trip>> watchUpcomingTrips() {
    return _trips
        .where('active', isEqualTo: true)
        .orderBy('when')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Trip.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList(),
        );
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

  // Requests (bookings)
  Future<DocumentReference> createRequest(
    String tripId,
    Map<String, dynamic> data,
  ) async {
    final col = _trips.doc(tripId).collection('requests');
    return await col.add(data);
  }

  Stream<List<RequestModel>> watchRequests(String tripId) {
    final col = _trips.doc(tripId).collection('requests');
    return col
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => RequestModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> rejectRequest(String tripId, String requestId) async {
    final ref = _trips.doc(tripId).collection('requests').doc(requestId);
    await ref.update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> hasPendingRequest(String tripId, String riderId) async {
    final col = _trips.doc(tripId).collection('requests');
    final snap = await col
        .where('riderId', isEqualTo: riderId)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> acceptRequest(String tripId, String requestId) async {
    final tripRef = _trips.doc(tripId);
    final reqRef = tripRef.collection('requests').doc(requestId);

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final tripSnap = await tx.get(tripRef);
      if (!tripSnap.exists) throw Exception('Trip not found');
      final tripData = tripSnap.data() as Map<String, dynamic>;
      final seats = (tripData['seats'] as num?)?.toInt() ?? 0;
      if (seats <= 0) throw Exception('No seats available');

      final reqSnap = await tx.get(reqRef);
      if (!reqSnap.exists) throw Exception('Request not found');
      final reqData = reqSnap.data() as Map<String, dynamic>;
      final status = reqData['status'] as String? ?? 'pending';
      if (status != 'pending') throw Exception('Request is not pending');

      // update request
      tx.update(reqRef, {
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // decrement seats and add passenger
      final newSeats = seats - 1;
      final Map<String, dynamic> updates = {'seats': newSeats};
      if (newSeats <= 0) updates['active'] = false;
      // add riderId to passengers array
      final riderId = reqData['riderId'] as String?;
      if (riderId != null) {
        updates['passengers'] = FieldValue.arrayUnion([riderId]);
      }
      tx.update(tripRef, updates);
    });
  }
}
