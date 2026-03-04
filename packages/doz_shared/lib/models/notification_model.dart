import 'enums.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final NotificationType type;
  final bool isRead;
  final String? referenceId;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.type,
    this.isRead = false,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      titleAr: json['titleAr'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      bodyAr: json['bodyAr'] as String? ?? '',
      bodyEn: json['bodyEn'] as String? ?? '',
      type: NotificationType.fromJson(json['type'] as String?),
      isRead: json['isRead'] as bool? ?? false,
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'bodyAr': bodyAr,
      'bodyEn': bodyEn,
      'type': type.toJson(),
      'isRead': isRead,
      if (referenceId != null) 'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? titleAr,
    String? titleEn,
    String? bodyAr,
    String? bodyEn,
    NotificationType? type,
    bool? isRead,
    String? referenceId,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      bodyAr: bodyAr ?? this.bodyAr,
      bodyEn: bodyEn ?? this.bodyEn,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String localizedTitle(String lang) => lang == 'ar' ? titleAr : titleEn;
  String localizedBody(String lang) => lang == 'ar' ? bodyAr : bodyEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'NotificationModel(id: $id, type: $type, isRead: $isRead)';
}
