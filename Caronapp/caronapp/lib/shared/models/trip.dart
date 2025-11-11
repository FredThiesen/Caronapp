import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String driverId;
  final String driverName;
  final String? driverAvatarUrl;
  final String origin;
  final String destination;
  final String whenLabel;
  final DateTime when;
  final int seats;
  final String? note;
  final bool active;

  const Trip({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.driverAvatarUrl,
    required this.origin,
    required this.destination,
    required this.whenLabel,
    required this.when,
    required this.seats,
    this.note,
    this.active = true,
  });

  factory Trip.fromMap(String id, Map<String, dynamic> map) => Trip(
    id: id,
    driverId: map['driverId'] as String? ?? '',
    driverName: map['driverName'] as String? ?? '',
    driverAvatarUrl: map['driverAvatarUrl'] as String?,
    origin: map['origin'] as String? ?? '',
    destination: map['destination'] as String? ?? '',
    whenLabel: map['whenLabel'] as String? ?? '',
    when: (map['when'] as Timestamp).toDate(),
    seats: (map['seats'] as num?)?.toInt() ?? 0,
    note: map['note'] as String?,
    active: map['active'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => {
    'driverId': driverId,
    'driverName': driverName,
    'driverAvatarUrl': driverAvatarUrl,
    'origin': origin,
    'destination': destination,
    'whenLabel': whenLabel,
    'when': Timestamp.fromDate(when),
    'seats': seats,
    'note': note,
    'active': active,
  };
}
