import 'user_model.dart';

class DriverModel {
  final String id;
  final String userId;
  final UserModel? user;
  final String licenseNumber;
  final String vehicleType;
  final String vehicleModel;
  final String vehicleColor;
  final String plateNumber;
  final double? lat;
  final double? lng;
  final double? heading;
  final bool isOnline;
  final bool isBusy;
  final double rating;
  final int totalRides;
  final double totalEarnings;

  const DriverModel({
    required this.id,
    required this.userId,
    this.user,
    required this.licenseNumber,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.plateNumber,
    this.lat,
    this.lng,
    this.heading,
    this.isOnline = false,
    this.isBusy = false,
    this.rating = 5.0,
    this.totalRides = 0,
    this.totalEarnings = 0.0,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] is Map
          ? (json['userId'] as Map<String, dynamic>)['_id'] as String? ?? ''
          : json['userId'] as String? ?? '',
      user: json['userId'] is Map
          ? UserModel.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      licenseNumber: json['licenseNumber'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleColor: json['vehicleColor'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      isOnline: json['isOnline'] as bool? ?? false,
      isBusy: json['isBusy'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: json['totalRides'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'licenseNumber': licenseNumber,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'plateNumber': plateNumber,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (heading != null) 'heading': heading,
      'isOnline': isOnline,
      'isBusy': isBusy,
      'rating': rating,
      'totalRides': totalRides,
      'totalEarnings': totalEarnings,
    };
  }

  DriverModel copyWith({
    String? id,
    String? userId,
    UserModel? user,
    String? licenseNumber,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    String? plateNumber,
    double? lat,
    double? lng,
    double? heading,
    bool? isOnline,
    bool? isBusy,
    double? rating,
    int? totalRides,
    double? totalEarnings,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      plateNumber: plateNumber ?? this.plateNumber,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      heading: heading ?? this.heading,
      isOnline: isOnline ?? this.isOnline,
      isBusy: isBusy ?? this.isBusy,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DriverModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DriverModel(id: $id, vehicleModel: $vehicleModel, isOnline: $isOnline)';
}
