import 'enums.dart';
import 'driver_model.dart';

class BidModel {
  final String id;
  final String rideId;
  final String driverId;
  final DriverModel? driver;
  final double amount;
  final BidStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const BidModel({
    required this.id,
    required this.rideId,
    required this.driverId,
    this.driver,
    required this.amount,
    this.status = BidStatus.pending,
    required this.createdAt,
    this.expiresAt,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      rideId: json['rideId'] is Map
          ? (json['rideId'] as Map<String, dynamic>)['_id'] as String? ?? ''
          : json['rideId'] as String? ?? '',
      driverId: json['driverId'] is Map
          ? (json['driverId'] as Map<String, dynamic>)['_id'] as String? ?? ''
          : json['driverId'] as String? ?? '',
      driver: json['driverId'] is Map
          ? DriverModel.fromJson(json['driverId'] as Map<String, dynamic>)
          : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: BidStatus.fromJson(json['status'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'driverId': driverId,
      'amount': amount,
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    };
  }

  BidModel copyWith({
    String? id,
    String? rideId,
    String? driverId,
    DriverModel? driver,
    double? amount,
    BidStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return BidModel(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BidModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BidModel(id: $id, amount: $amount, status: $status)';
}
