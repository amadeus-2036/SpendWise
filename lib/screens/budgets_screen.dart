import 'package:flutter/material.dart';
import '../models/budget_item.dart';
import '../models/transaction_item.dart';
import '../models/app_category.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/edit_budget_modal.dart';

/// Screen for viewing and managing category monthly budgets with warning notifications.
class BudgetsScreen extends StatefulWidget {
  final List<BudgetItem> budgets;
  final List<TransactionItem> transactions;
  final String currency;
  final Function(List<BudgetItem>) onSaveBudgets;

  const BudgetsScreen({
    super.key,
    required this.budgets,
    required this.transactions,
    required this.currency,
    required this.onSaveBudgets,
  });

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late List<BudgetItem> _budgets;

  @override
  void initState() {
    super.initState();
    _budgets = List<BudgetItem>.from(widget.budgets);
  }

  @override
  void didUpdateWidget(covariant BudgetsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.budgets != oldWidget.budgets) {
      _budgets = List<BudgetItem>.from(widget.budgets);
    }
  }

  void _editBudget(BudgetItem budget) {
    showDialog(
      context: context,
      builder: (context) => EditBudgetModal(
        budget: budget,
        currency: widget.currency,
        onSave: (updated) {
          final updatedList = _budgets.map((b) {
            return b.category == updated.category ? updated : b;
          }).toList();
          setState(() {
            _budgets = updatedList;
          });
          widget.onSaveBudgets(updatedList);
        },
      ),
    );
  }

  void _addNewCategoryBudget() {
    // Determine categories not yet budgeted
    final existingNames = _budgets.map((b) => b.category).toSet();
    final remainingCategories = AppCategory.expenseCategories
        .where((c) => !existingNames.contains(c.name))
        .toList();

    if (remainingCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All expense categories already have budgets.')),
      );
      return;
    }

    String selectedCategory = remainingCategories.first.name;
    final limitController = TextEditingController(text: '200');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Category Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Category:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: remainingCategories.map((c) {
                  return DropdownMenuItem(
                    value: c.name,
                    child: Row(
                      children: [
                        Icon(c.icon, size: 18, color: c.color),
                        const SizedBox(width: 8),
                        Text(c.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Monthly Limit:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '${CurrencyHelper.getSymbol(widget.currency)} ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final limit = double.tryParse(limitController.text.trim()) ?? 0.0;
                if (limit > 0) {
                  final newBudgets = List<BudgetItem>.from(_budgets)
                    ..add(BudgetItem(category: selectedCategory, monthlyLimit: limit));
                  setState(() {
                    _budgets = newBudgets;
                  });
                  widget.onSaveBudgets(newBudgets);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add Budget'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate current month's expenses per category
    final now = DateTime.now();
    final Map<String, double> categorySpent = {};
    double totalMonthSpent = 0.0;

    for (final tx in widget.transactions) {
      if (tx.isExpense && tx.date.year == now.year && tx.date.month == now.month) {
        categorySpent[tx.category] = (categorySpent[tx.category] ?? 0.0) + tx.amount;
        totalMonthSpent += tx.amount;
      }
    }

    double totalLimit = 0.0;
    int exceededCount = 0;
    int warningCount = 0;

    for (final b in _budgets) {
      totalLimit += b.monthlyLimit;
      final spent = categorySpent[b.category] ?? 0.0;
      if (spent > b.monthlyLimit) {
        exceededCount++;
      } else if (b.monthlyLimit > 0 && (spent / b.monthlyLimit) >= 0.8) {
        warningCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Budget',
            onPressed: _addNewCategoryBudget,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total budget overview card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.cardNavyGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Monthly Spending Limit',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyHelper.format(totalLimit, widget.currency),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Spent: ${CurrencyHelper.format(totalMonthSpent, widget.currency)}',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      Text(
                        '${totalLimit > 0 ? ((totalMonthSpent / totalLimit) * 100).toStringAsFixed(0) : 0}% Utilized',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Warning Banner if exceeded or near limit
            if (exceededCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.expense.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.expense.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.expense, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Budget Warning: You have exceeded budget in $exceededCount ${exceededCount == 1 ? 'category' : 'categories'}.',
                        style: const TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (warningCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Heads up: $warningCount ${warningCount == 1 ? 'category is' : 'categories are'} above 80% of limit.',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Category budgets list
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),

            ..._budgets.map((budget) {
              final spent = categorySpent[budget.category] ?? 0.0;
              return BudgetProgressCard(
                budget: budget,
                currentSpent: spent,
                currency: widget.currency,
                onEdit: () => _editBudget(budget),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
