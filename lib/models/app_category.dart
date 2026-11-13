import 'package:flutter/material.dart';

/// Represents spending and income categories in SpendWise.
class AppCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isDefaultExpense;

  const AppCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefaultExpense = true,
  });

  /// Predefined expense categories
  static const List<AppCategory> expenseCategories = [
    AppCategory(
      id: 'Food & Dining',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFF97316), // Orange
    ),
    AppCategory(
      id: 'Shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFEC4899), // Pink
    ),
    AppCategory(
      id: 'Bills & Utilities',
      name: 'Bills & Utilities',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF3B82F6), // Blue
    ),
    AppCategory(
      id: 'Transportation',
      name: 'Transportation',
      icon: Icons.directions_car_outlined,
      color: Color(0xFF06B6D4), // Cyan
    ),
    AppCategory(
      id: 'Entertainment',
      name: 'Entertainment',
      icon: Icons.movie_outlined,
      color: Color(0xFF8B5CF6), // Purple
    ),
    AppCategory(
      id: 'Healthcare',
      name: 'Healthcare',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF10B981), // Emerald
    ),
    AppCategory(
      id: 'Education',
      name: 'Education',
      icon: Icons.school_outlined,
      color: Color(0xFF6366F1), // Indigo
    ),
    AppCategory(
      id: 'Other Expense',
      name: 'Other Expense',
      icon: Icons.category_outlined,
      color: Color(0xFF64748B), // Slate
    ),
  ];

  /// Predefined income categories
  static const List<AppCategory> incomeCategories = [
    AppCategory(
      id: 'Salary',
      name: 'Salary',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF10B981), // Green
      isDefaultExpense: false,
    ),
    AppCategory(
      id: 'Freelance & Side Gig',
      name: 'Freelance & Side Gig',
      icon: Icons.laptop_chromebook,
      color: Color(0xFF3B82F6), // Blue
      isDefaultExpense: false,
    ),
    AppCategory(
      id: 'Investments',
      name: 'Investments',
      icon: Icons.trending_up,
      color: Color(0xFF8B5CF6), // Purple
      isDefaultExpense: false,
    ),
    AppCategory(
      id: 'Gifts & Rewards',
      name: 'Gifts & Rewards',
      icon: Icons.card_giftcard,
      color: Color(0xFFF59E0B), // Amber
      isDefaultExpense: false,
    ),
    AppCategory(
      id: 'Other Income',
      name: 'Other Income',
      icon: Icons.add_circle_outline,
      color: Color(0xFF14B8A6), // Teal
      isDefaultExpense: false,
    ),
  ];

  /// Combined list of all categories
  static List<AppCategory> get allCategories => [
        ...expenseCategories,
        ...incomeCategories,
      ];

  /// Find category by name with fallback
  static AppCategory findCategory(String name) {
    return allCategories.firstWhere(
      (cat) => cat.id.toLowerCase() == name.toLowerCase() || cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => const AppCategory(
        id: 'Other',
        name: 'Other',
        icon: Icons.monetization_on_outlined,
        color: Color(0xFF64748B),
      ),
    );
  }
}

