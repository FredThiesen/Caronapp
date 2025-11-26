import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String riderId;
  final String riderName;
  final String? message;
  final String status; // pending | accepted | rejected
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RequestModel({
    required this.id,
    required this.riderId,
    required this.riderName,
    this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestModel.fromMap(String id, Map<String, dynamic> map) =>
      RequestModel(
        id: id,
        riderId: map['riderId'] as String? ?? '',
        riderName: map['riderName'] as String? ?? '',
        message: map['message'] as String?,
        status: map['status'] as String? ?? 'pending',
        createdAt: (map['createdAt'] is Timestamp)
            ? (map['createdAt'] as Timestamp).toDate()
            : null,
        updatedAt: (map['updatedAt'] is Timestamp)
            ? (map['updatedAt'] as Timestamp).toDate()
            : null,
      );

  Map<String, dynamic> toMap() => {
    'riderId': riderId,
    'riderName': riderName,
    'message': message,
    'status': status,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
    'updatedAt': updatedAt != null
        ? Timestamp.fromDate(updatedAt!)
        : FieldValue.serverTimestamp(),
  };
}
