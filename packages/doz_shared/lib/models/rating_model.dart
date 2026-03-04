class RatingModel {
  final String id;
  final String rideId;
  final String fromUserId;
  final String toUserId;
  final int stars;
  final List<String> tags;
  final String? comment;
  final DateTime createdAt;

  const RatingModel({
    required this.id,
    required this.rideId,
    required this.fromUserId,
    required this.toUserId,
    required this.stars,
    this.tags = const [],
    this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      rideId: json['rideId'] as String? ?? '',
      fromUserId: json['fromUserId'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? '',
      stars: json['stars'] as int? ?? 5,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'stars': stars,
      'tags': tags,
      if (comment != null) 'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RatingModel copyWith({
    String? id,
    String? rideId,
    String? fromUserId,
    String? toUserId,
    int? stars,
    List<String>? tags,
    String? comment,
    DateTime? createdAt,
  }) {
    return RatingModel(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      stars: stars ?? this.stars,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RatingModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'RatingModel(id: $id, stars: $stars, rideId: $rideId)';
}
