/// Represents a category's monthly spending budget.
class BudgetItem {
  final String category;
  final double monthlyLimit;

  BudgetItem({
    required this.category,
    required this.monthlyLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'monthlyLimit': monthlyLimit,
    };
  }

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      category: json['category'] as String,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }

  BudgetItem copyWith({
    String? category,
    double? monthlyLimit,
  }) {
    return BudgetItem(
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }
}

