import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../models/budget_item.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state_view.dart';

/// Dashboard screen showing total balance, monthly summary, quick actions, and recent transactions.
class DashboardScreen extends StatelessWidget {
  final List<TransactionItem> transactions;
  final List<BudgetItem> budgets;
  final String currency;
  final VoidCallback onAddTransaction;
  final Function(TransactionItem) onEditTransaction;
  final VoidCallback onViewAllTransactions;
  final VoidCallback onOpenBudgets;
  final VoidCallback onOpenCurrencyConverter;
  final Function(String id) onDeleteTransaction;

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.budgets,
    required this.currency,
    required this.onAddTransaction,
    required this.onEditTransaction,
    required this.onViewAllTransactions,
    required this.onOpenBudgets,
    required this.onOpenCurrencyConverter,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Financial calculations
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    final now = DateTime.now();
    double currentMonthExpense = 0.0;

    for (final tx in transactions) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
        if (tx.date.year == now.year && tx.date.month == now.month) {
          currentMonthExpense += tx.amount;
        }
      } else {
        totalIncome += tx.amount;
      }
    }

    final totalBalance = totalIncome - totalExpense;

    // Total monthly budget limit
    double totalMonthlyBudget = 0.0;
    for (final b in budgets) {
      totalMonthlyBudget += b.monthlyLimit;
    }

    // Recent 5 transactions sorted by date descending
    final sortedTransactions = List<TransactionItem>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedTransactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wallet, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('SpendWise'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange_outlined),
            tooltip: 'Live Currency Converter',
            onPressed: onOpenCurrencyConverter,
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'Monthly Budgets',
            onPressed: onOpenBudgets,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Parent handles updates reactively
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Balance and Summary Card
              SummaryCard(
                totalBalance: totalBalance,
                totalIncome: totalIncome,
                totalExpense: totalExpense,
                currency: currency,
                onAddTap: onAddTransaction,
              ),
              const SizedBox(height: 18),

              // 2. Quick Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: _buildActionItem(
                      context: context,
                      icon: Icons.add_circle_outline,
                      label: 'Add Entry',
                      color: AppColors.primary,
                      onTap: onAddTransaction,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionItem(
                      context: context,
                      icon: Icons.track_changes_outlined,
                      label: 'Budgets',
                      color: AppColors.accent,
                      onTap: onOpenBudgets,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionItem(
                      context: context,
                      icon: Icons.currency_exchange,
                      label: 'Converter',
                      color: const Color(0xFF0EA5E9),
                      onTap: onOpenCurrencyConverter,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Monthly Spending & Budget Health Banner
              if (totalMonthlyBudget > 0)
                _buildMonthlyBudgetBanner(
                  context: context,
                  spent: currentMonthExpense,
                  limit: totalMonthlyBudget,
                  currency: currency,
                  onTap: onOpenBudgets,
                ),
              const SizedBox(height: 22),

              // 4. Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (transactions.isNotEmpty)
                    TextButton(
                      onPressed: onViewAllTransactions,
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // 5. Recent Transactions List or Empty State
              if (recentTransactions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    message: 'Tap "+ Add Entry" above to record your first income or expense.',
                    actionText: 'Add First Transaction',
                    onAction: onAddTransaction,
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = recentTransactions[index];
                    return TransactionTile(
                      transaction: tx,
                      currency: currency,
                      onTap: () => onEditTransaction(tx),
                      onDelete: () => onDeleteTransaction(tx.id),
                    );
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBudgetBanner({
    required BuildContext context,
    required double spent,
    required double limit,
    required String currency,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ratio = (spent / limit).clamp(0.0, 1.0);
    final percent = ((spent / limit) * 100).toStringAsFixed(0);
    final isOver = spent > limit;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOver
                ? AppColors.expense.withOpacity(0.4)
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, size: 18, color: AppColors.primaryLight),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly Budget Utilization',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isOver ? AppColors.expense : AppColors.primaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOver
                      ? AppColors.expense
                      : (ratio > 0.8 ? AppColors.warning : AppColors.income),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${CurrencyHelper.format(spent, currency)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  'Budget: ${CurrencyHelper.format(limit, currency)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
