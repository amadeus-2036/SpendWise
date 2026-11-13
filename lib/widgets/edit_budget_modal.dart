import 'package:flutter/material.dart';
import '../models/budget_item.dart';
import '../models/app_category.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';

/// Modal dialog to set or update a monthly budget limit for a specific category.
class EditBudgetModal extends StatefulWidget {
  final BudgetItem budget;
  final String currency;
  final Function(BudgetItem) onSave;

  const EditBudgetModal({
    super.key,
    required this.budget,
    required this.currency,
    required this.onSave,
  });

  @override
  State<EditBudgetModal> createState() => _EditBudgetModalState();
}

class _EditBudgetModalState extends State<EditBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.budget.monthlyLimit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final limit = double.tryParse(_limitController.text.trim()) ?? 0.0;
    if (limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget limit must be greater than 0'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    widget.onSave(widget.budget.copyWith(monthlyLimit: limit));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catInfo = AppCategory.findCategory(widget.budget.category);

    return AlertDialog(
      title: Row(
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
            child: Text(
              'Set Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${widget.budget.category}',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Monthly Spending Limit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _limitController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    CurrencyHelper.getSymbol(widget.currency),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Enter budget amount';
                if (double.tryParse(val.trim()) == null) return 'Enter valid number';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Save Limit'),
        ),
      ],
    );
  }
}

