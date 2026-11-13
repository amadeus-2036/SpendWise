import 'package:flutter/material.dart';
import '../models/budget_item.dart';
import '../models/app_category.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';

/// Card showing progress for a single category budget with warning indicators.
class BudgetProgressCard extends StatelessWidget {
  final BudgetItem budget;
  final double currentSpent;
  final String currency;
  final VoidCallback onEdit;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    required this.currentSpent,
    required this.currency,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catInfo = AppCategory.findCategory(budget.category);

    final ratio = budget.monthlyLimit > 0 ? (currentSpent / budget.monthlyLimit) : 0.0;
    final percentage = (ratio * 100).clamp(0, 999).toDouble();
    final isExceeded = currentSpent > budget.monthlyLimit;
    final isWarning = !isExceeded && ratio >= 0.8;
    final remaining = budget.monthlyLimit - currentSpent;

    // Status chip colors and text
    Color statusColor;
    String statusText;
    if (isExceeded) {
      statusColor = AppColors.expense;
      statusText = 'Exceeded';
    } else if (isWarning) {
      statusColor = AppColors.warning;
      statusText = 'Near Limit';
    } else {
      statusColor = AppColors.income;
      statusText = 'On Track';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExceeded
              ? AppColors.expense.withOpacity(0.4)
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: isExceeded ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon, Category Name, Status chip and Edit button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: catInfo.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(catInfo.icon, color: catInfo.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isExceeded
                          ? 'Over budget by ${CurrencyHelper.format(currentSpent - budget.monthlyLimit, currency)}'
                          : '${CurrencyHelper.format(remaining, currency)} remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExceeded
                            ? AppColors.expense
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        fontWeight: isExceeded ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                tooltip: 'Edit Budget Limit',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (ratio).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 10),

          // Amount and percentage details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: ${CurrencyHelper.format(currentSpent, currency)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                'Limit: ${CurrencyHelper.format(budget.monthlyLimit, currency)} (${percentage.toStringAsFixed(0)}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

