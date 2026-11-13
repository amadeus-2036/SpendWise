import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../models/budget_item.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/monthly_bar_chart.dart';

/// Analytics screen featuring Donut Chart, Monthly Bar Chart, and Budget Utilization Summary.
class AnalyticsScreen extends StatefulWidget {
  final List<TransactionItem> transactions;
  final List<BudgetItem> budgets;
  final String currency;
  final VoidCallback onOpenBudgets;

  const AnalyticsScreen({
    super.key,
    required this.transactions,
    required this.budgets,
    required this.currency,
    required this.onOpenBudgets,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isThisMonthOnly = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();

    // Current month calculations
    double currentMonthIncome = 0.0;
    double currentMonthExpense = 0.0;
    final Map<String, double> currentMonthCategoryExpenses = {};

    for (final tx in widget.transactions) {
      if (tx.date.year == now.year && tx.date.month == now.month) {
        if (tx.isExpense) {
          currentMonthExpense += tx.amount;
          currentMonthCategoryExpenses[tx.category] =
              (currentMonthCategoryExpenses[tx.category] ?? 0.0) + tx.amount;
        } else {
          currentMonthIncome += tx.amount;
        }
      }
    }

    // Total monthly budget limit
    double totalBudget = 0.0;
    for (final b in widget.budgets) {
      totalBudget += b.monthlyLimit;
    }

    // Top spending category for current month
    String topCategory = 'None';
    double topCategoryAmount = 0.0;
    currentMonthCategoryExpenses.forEach((cat, amt) {
      if (amt > topCategoryAmount) {
        topCategoryAmount = amt;
        topCategory = cat;
      }
    });

    // Savings rate for current month
    final savings = currentMonthIncome - currentMonthExpense;
    final savingsRate = currentMonthIncome > 0
        ? ((savings / currentMonthIncome) * 100).clamp(-999.0, 100.0)
        : 0.0;

    final budgetRatio = totalBudget > 0 ? (currentMonthExpense / totalBudget) : 0.0;
    final budgetPercent = (budgetRatio * 100).clamp(0, 999).toDouble();

    // Transactions filtered for donut chart based on toggle
    final donutTransactions = _isThisMonthOnly
        ? widget.transactions
            .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
            .toList()
        : widget.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Budget Settings',
            onPressed: widget.onOpenBudgets,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Budget Utilisation Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.analytics_outlined, color: AppColors.primaryLight, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Monthly Budget Health',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: widget.onOpenBudgets,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            'Manage',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: budgetRatio.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        currentMonthExpense > totalBudget
                            ? AppColors.expense
                            : (budgetRatio > 0.8 ? AppColors.warning : AppColors.income),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3 Stat Badges
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCol(
                          title: 'Spent',
                          value: CurrencyHelper.format(currentMonthExpense, widget.currency, compact: true),
                          color: AppColors.expense,
                          isDark: isDark,
                        ),
                      ),
                      Container(width: 1, height: 28, color: Colors.grey.withOpacity(0.2)),
                      Expanded(
                        child: _buildMetricCol(
                          title: 'Budget',
                          value: CurrencyHelper.format(totalBudget, widget.currency, compact: true),
                          color: AppColors.primaryLight,
                          isDark: isDark,
                        ),
                      ),
                      Container(width: 1, height: 28, color: Colors.grey.withOpacity(0.2)),
                      Expanded(
                        child: _buildMetricCol(
                          title: 'Utilized',
                          value: '${budgetPercent.toStringAsFixed(0)}%',
                          color: budgetPercent > 100
                              ? AppColors.expense
                              : (budgetPercent > 80 ? AppColors.warning : AppColors.income),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Savings Rate & Top Expense Highlights
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              savingsRate >= 0 ? Icons.trending_up : Icons.trending_down,
                              color: savingsRate >= 0 ? AppColors.income : AppColors.expense,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Savings Rate: ${savingsRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_outlined, color: AppColors.warning, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Top: $topCategory',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Category Expense Donut Chart Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expenses by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isThisMonthOnly ? 'Showing current month' : 'Showing all-time history',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                // Timeframe Toggle Pill
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTimeToggle(
                        label: 'Month',
                        selected: _isThisMonthOnly,
                        onTap: () => setState(() => _isThisMonthOnly = true),
                        isDark: isDark,
                      ),
                      _buildTimeToggle(
                        label: 'All Time',
                        selected: !_isThisMonthOnly,
                        onTap: () => setState(() => _isThisMonthOnly = false),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: CategoryDonutChart(
                transactions: donutTransactions,
                currency: widget.currency,
              ),
            ),
            const SizedBox(height: 28),

            // 3. Monthly Expenses Bar Chart Section
            Text(
              'Monthly Spending Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Overview of total spending across recent months',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: MonthlyBarChart(
                transactions: widget.transactions,
                currency: widget.currency,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToggle({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCol({
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
