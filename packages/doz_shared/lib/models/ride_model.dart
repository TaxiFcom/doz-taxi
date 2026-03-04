import 'enums.dart';
import 'driver_model.dart';
import 'user_model.dart';

class RideModel {
  final String id;
  final String riderId;
  final UserModel? rider;
  final String? driverId;
  final DriverModel? driver;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String dropoffAddress;
  final RideStatus status;
  final double suggestedPrice;
  final double? finalPrice;
  final double? distanceKm;
  final int? durationMin;
  final double? commissionAmount;
  final PaymentMethod paymentMethod;
  final String? vehicleType;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const RideModel({
    required this.id,
    required this.riderId,
    this.rider,
    this.driverId,
    this.driver,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.dropoffAddress,
    required this.status,
    required this.suggestedPrice,
    this.finalPrice,
    this.distanceKm,
    this.durationMin,
    this.commissionAmount,
    this.paymentMethod = PaymentMethod.cash,
    this.vehicleType,
    this.cancelReason,
    required this.createdAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      riderId: json['riderId'] is Map
          ? (json['riderId'] as Map<String, dynamic>)['_id'] as String? ?? ''
          : json['riderId'] as String? ?? '',
      rider: json['riderId'] is Map
          ? UserModel.fromJson(json['riderId'] as Map<String, dynamic>)
          : null,
      driverId: json['driverId'] is Map
          ? (json['driverId'] as Map<String, dynamic>)['_id'] as String?
          : json['driverId'] as String?,
      driver: json['driverId'] is Map
          ? DriverModel.fromJson(json['driverId'] as Map<String, dynamic>)
          : null,
      pickupLat: (json['pickupLat'] as num?)?.toDouble() ?? 0.0,
      pickupLng: (json['pickupLng'] as num?)?.toDouble() ?? 0.0,
      pickupAddress: json['pickupAddress'] as String? ?? '',
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble() ?? 0.0,
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble() ?? 0.0,
      dropoffAddress: json['dropoffAddress'] as String? ?? '',
      status: RideStatus.fromJson(json['status'] as String?),
      suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      durationMin: json['durationMin'] as int?,
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      paymentMethod:
          PaymentMethod.fromJson(json['paymentMethod'] as String?),
      vehicleType: json['vehicleType'] as String?,
      cancelReason: json['cancelReason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      arrivedAt: json['arrivedAt'] != null
          ? DateTime.parse(json['arrivedAt'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'riderId': riderId,
      if (driverId != null) 'driverId': driverId,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupAddress': pickupAddress,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'dropoffAddress': dropoffAddress,
      'status': status.toJson(),
      'suggestedPrice': suggestedPrice,
      if (finalPrice != null) 'finalPrice': finalPrice,
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (durationMin != null) 'durationMin': durationMin,
      if (commissionAmount != null) 'commissionAmount': commissionAmount,
      'paymentMethod': paymentMethod.toJson(),
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (cancelReason != null) 'cancelReason': cancelReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RideModel copyWith({
    String? id,
    String? riderId,
    UserModel? rider,
    String? driverId,
    DriverModel? driver,
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    double? dropoffLat,
    double? dropoffLng,
    String? dropoffAddress,
    RideStatus? status,
    double? suggestedPrice,
    double? finalPrice,
    double? distanceKm,
    int? durationMin,
    double? commissionAmount,
    PaymentMethod? paymentMethod,
    String? vehicleType,
    String? cancelReason,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      rider: rider ?? this.rider,
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      status: status ?? this.status,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vehicleType: vehicleType ?? this.vehicleType,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get isActive =>
      status != RideStatus.completed && status != RideStatus.cancelled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RideModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RideModel(id: $id, status: $status)';
}
