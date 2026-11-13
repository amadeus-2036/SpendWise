import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_item.dart';
import '../models/app_category.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';

/// Donut chart displaying expense breakdown by category with interactive touch selection.
class CategoryDonutChart extends StatefulWidget {
  final List<TransactionItem> transactions;
  final String currency;

  const CategoryDonutChart({
    super.key,
    required this.transactions,
    required this.currency,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter to only expenses
    final expenses = widget.transactions.where((tx) => tx.isExpense).toList();

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    double grandTotal = 0.0;

    for (final tx in expenses) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0.0) + tx.amount;
      grandTotal += tx.amount;
    }

    if (grandTotal == 0 || categoryTotals.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 48,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
            const SizedBox(height: 10),
            Text(
              'No expense data to analyze yet',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Sort categories from largest spending to smallest
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Build pie chart sections
    final sections = <PieChartSectionData>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final isTouched = i == _touchedIndex;
      final category = AppCategory.findCategory(entry.key);
      final percentage = (entry.value / grandTotal) * 100;
      final radius = isTouched ? 45.0 : 36.0;

      sections.add(
        PieChartSectionData(
          color: category.color,
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: isTouched ? 14 : 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 2),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Donut Chart with Center Total
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 55,
                  sections: sections,
                ),
              ),
              // Center Label
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Spent',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyHelper.format(grandTotal, widget.currency, compact: true),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Category Breakdown Legend
        Column(
          children: sortedEntries.map((entry) {
            final category = AppCategory.findCategory(entry.key);
            final percentage = (entry.value / grandTotal) * 100;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyHelper.format(entry.value, widget.currency),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

