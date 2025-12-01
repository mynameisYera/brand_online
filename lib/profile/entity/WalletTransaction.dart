class WalletTransaction {
  final int id;
  final int amount;
  final String type;
  final String text;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.text,
    required this.metadata,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: json['amount'],
      type: json['type'],
      text: json['text'],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
