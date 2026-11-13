import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../models/app_category.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state_view.dart';

/// Transactions screen supporting filtering by type, category, text search, editing, and deletion.
class TransactionsScreen extends StatefulWidget {
  final List<TransactionItem> transactions;
  final String currency;
  final VoidCallback onAddTransaction;
  final Function(TransactionItem) onEditTransaction;
  final Function(String id) onDeleteTransaction;

  const TransactionsScreen({
    super.key,
    required this.transactions,
    required this.currency,
    required this.onAddTransaction,
    required this.onEditTransaction,
    required this.onDeleteTransaction,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filters
  String _selectedType = 'ALL'; // 'ALL', 'EXPENSE', 'INCOME'
  String _selectedCategory = 'ALL'; // 'ALL' or specific category name

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter logic
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.transactions.where((tx) {
      // Type filter
      if (_selectedType == 'EXPENSE' && !tx.isExpense) return false;
      if (_selectedType == 'INCOME' && tx.isExpense) return false;

      // Category filter
      if (_selectedCategory != 'ALL' && tx.category != _selectedCategory) {
        return false;
      }

      // Search query
      if (query.isNotEmpty) {
        final matchesTitle = tx.title.toLowerCase().contains(query);
        final matchesCategory = tx.category.toLowerCase().contains(query);
        final matchesNotes = tx.notes?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesCategory && !matchesNotes) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort newest first
    filtered.sort((a, b) => b.date.compareTo(a.date));

    // Calculate total for filtered list
    double filteredSum = 0.0;
    for (final tx in filtered) {
      if (tx.isExpense) {
        filteredSum -= tx.amount;
      } else {
        filteredSum += tx.amount;
      }
    }

    // List of unique categories present in all categories
    final allCategoryNames = <String>{'ALL'};
    for (final cat in AppCategory.allCategories) {
      allCategoryNames.add(cat.name);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Transaction',
            onPressed: widget.onAddTransaction,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by title, note, or category...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // 2. Transaction Type Filter Pills (All, Expenses, Income)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildTypePill('ALL', 'All'),
                const SizedBox(width: 8),
                _buildTypePill('EXPENSE', 'Expenses Only'),
                const SizedBox(width: 8),
                _buildTypePill('INCOME', 'Income Only'),
              ],
            ),
          ),

          // 3. Category Filter Chips (Horizontally Scrollable)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: allCategoryNames.map((catName) {
                final isSelected = _selectedCategory == catName;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      catName == 'ALL' ? 'All Categories' : catName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? catName : 'ALL';
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // 4. Results Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'transaction' : 'transactions'} found (Tap to edit)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  'Net: ${filteredSum >= 0 ? '+' : ''}${CurrencyHelper.format(filteredSum, widget.currency)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: filteredSum >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),

          // 5. Transaction List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateView(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No matching transactions',
                    message: widget.transactions.isEmpty
                        ? 'You haven’t recorded any transactions yet.'
                        : 'Try adjusting your search query or active filter chips.',
                    actionText: widget.transactions.isEmpty ? 'Add Transaction' : 'Clear Filters',
                    onAction: widget.transactions.isEmpty
                        ? widget.onAddTransaction
                        : () {
                            setState(() {
                              _searchController.clear();
                              _selectedType = 'ALL';
                              _selectedCategory = 'ALL';
                            });
                          },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return TransactionTile(
                        transaction: tx,
                        currency: widget.currency,
                        onTap: () => widget.onEditTransaction(tx),
                        onDelete: () => widget.onDeleteTransaction(tx.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePill(String typeKey, String label) {
    final isSelected = _selectedType == typeKey;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = typeKey;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
