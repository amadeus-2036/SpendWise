/// Represents an individual income or expense transaction.
class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isExpense;
  final String? notes;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
    this.notes,
  });

  /// Convert to JSON Map for SharedPreferences persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
      'notes': notes,
    };
  }

  /// Factory constructor to deserialize from JSON Map
  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      isExpense: json['isExpense'] as bool,
      notes: json['notes'] as String?,
    );
  }

  /// Create a copy with optional updated fields
  TransactionItem copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isExpense,
    String? notes,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      notes: notes ?? this.notes,
    );
  }
}

