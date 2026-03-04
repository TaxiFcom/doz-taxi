class VehicleTypeModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;
  final double baseFare;
  final double perKm;
  final double perMin;
  final double minFare;
  final bool isActive;
  final int sortOrder;

  const VehicleTypeModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.baseFare,
    required this.perKm,
    required this.perMin,
    required this.minFare,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      icon: json['icon'] as String? ?? '\u{1F697}',
      baseFare: (json['baseFare'] as num?)?.toDouble() ?? 0.0,
      perKm: (json['perKm'] as num?)?.toDouble() ?? 0.0,
      perMin: (json['perMin'] as num?)?.toDouble() ?? 0.0,
      minFare: (json['minFare'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'icon': icon,
      'baseFare': baseFare,
      'perKm': perKm,
      'perMin': perMin,
      'minFare': minFare,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  VehicleTypeModel copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? icon,
    double? baseFare,
    double? perKm,
    double? perMin,
    double? minFare,
    bool? isActive,
    int? sortOrder,
  }) {
    return VehicleTypeModel(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      baseFare: baseFare ?? this.baseFare,
      perKm: perKm ?? this.perKm,
      perMin: perMin ?? this.perMin,
      minFare: minFare ?? this.minFare,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Calculate estimated fare given distance (km) and duration (min)
  double estimateFare(double distanceKm, int durationMin) {
    final fare =
        baseFare + (perKm * distanceKm) + (perMin * durationMin);
    return fare < minFare ? minFare : fare;
  }

  String localizedName(String lang) => lang == 'ar' ? nameAr : nameEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleTypeModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VehicleTypeModel(id: $id, nameEn: $nameEn, baseFare: $baseFare)';
}
