import 'wallet_transaction_model.dart';

class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final List<WalletTransactionModel> transactions;
  final DateTime updatedAt;

  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'JOD',
    this.transactions = const [],
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'JOD',
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => WalletTransactionModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'balance': balance,
      'currency': currency,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WalletModel copyWith({
    String? id,
    String? userId,
    double? balance,
    String? currency,
    List<WalletTransactionModel>? transactions,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      transactions: transactions ?? this.transactions,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is WalletModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WalletModel(id: $id, balance: $balance $currency)';
}
