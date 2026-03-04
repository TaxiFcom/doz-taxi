import 'enums.dart';

class WalletTransactionModel {
  final String id;
  final double amount;
  final WalletTransactionType type;
  final String description;
  final String? reference;
  final double balanceAfter;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    this.reference,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: WalletTransactionType.fromJson(json['type'] as String?),
      description: json['description'] as String? ?? '',
      reference: json['reference'] as String?,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.toJson(),
      'description': description,
      if (reference != null) 'reference': reference,
      'balanceAfter': balanceAfter,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WalletTransactionModel copyWith({
    String? id,
    double? amount,
    WalletTransactionType? type,
    String? description,
    String? reference,
    double? balanceAfter,
    DateTime? createdAt,
  }) {
    return WalletTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isCredit =>
      type == WalletTransactionType.topUp ||
      type == WalletTransactionType.refund;

  bool get isDebit =>
      type == WalletTransactionType.payment ||
      type == WalletTransactionType.commission ||
      type == WalletTransactionType.withdrawal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletTransactionModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WalletTransactionModel(id: $id, amount: $amount, type: $type)';
}
