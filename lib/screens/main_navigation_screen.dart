import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../models/budget_item.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/add_transaction_modal.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'analytics_screen.dart';
import 'budgets_screen.dart';
import 'currency_converter_screen.dart';
import 'settings_screen.dart';

/// Root navigation shell housing BottomNavigationBar, state coordination, and quick actions.
class MainNavigationScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode currentThemeMode;

  const MainNavigationScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  List<TransactionItem> _transactions = [];
  List<BudgetItem> _budgets = [];
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final txs = await StorageService.loadTransactions();
    final budgets = await StorageService.loadBudgets();
    final currency = await StorageService.getCurrency();

    setState(() {
      _transactions = txs;
      _budgets = budgets;
      _currency = currency;
      _isLoading = false;
    });
  }

  // --- Transaction Actions ---
  void _saveTransaction(TransactionItem tx) {
    final index = _transactions.indexWhere((t) => t.id == tx.id);
    setState(() {
      if (index >= 0) {
        _transactions[index] = tx;
      } else {
        _transactions.insert(0, tx);
      }
    });
    StorageService.saveTransactions(_transactions);
  }

  void _deleteTransaction(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final removedTx = _transactions[index];
    setState(() {
      _transactions.removeAt(index);
    });
    StorageService.saveTransactions(_transactions);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removedTx.title}"'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.income,
          onPressed: () {
            setState(() {
              _transactions.insert(index, removedTx);
            });
            StorageService.saveTransactions(_transactions);
          },
        ),
      ),
    );
  }

  // --- Budget Actions ---
  void _saveBudgets(List<BudgetItem> updatedBudgets) {
    setState(() {
      _budgets = updatedBudgets;
    });
    StorageService.saveBudgets(updatedBudgets);
  }

  // --- Settings Actions ---
  void _changeCurrency(String newCurrency) {
    setState(() {
      _currency = newCurrency;
    });
    StorageService.setCurrency(newCurrency);
  }

  void _changeTheme(String mode) {
    StorageService.setThemeMode(mode);
    widget.onThemeChanged(mode == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _resetSampleData() async {
    await StorageService.resetToSampleData();
    await _loadAllData();
  }

  Future<void> _clearAllTransactions() async {
    await StorageService.clearAllTransactions();
    setState(() {
      _transactions = [];
    });
  }

  // --- Modals & Sub-screens Navigation ---
  void _openAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddTransactionModal(
        currency: _currency,
        onSave: _saveTransaction,
      ),
    );
  }

  void _openEditTransactionModal(TransactionItem tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddTransactionModal(
        currency: _currency,
        initialTransaction: tx,
        onSave: _saveTransaction,
      ),
    );
  }

  void _navigateToBudgets() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BudgetsScreen(
          budgets: _budgets,
          transactions: _transactions,
          currency: _currency,
          onSaveBudgets: _saveBudgets,
        ),
      ),
    );
  }

  void _navigateToCurrencyConverter() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CurrencyConverterScreen(
          initialCurrency: _currency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pages = [
      DashboardScreen(
        transactions: _transactions,
        budgets: _budgets,
        currency: _currency,
        onAddTransaction: _openAddTransactionModal,
        onEditTransaction: _openEditTransactionModal,
        onViewAllTransactions: () => setState(() => _currentIndex = 1),
        onOpenBudgets: _navigateToBudgets,
        onOpenCurrencyConverter: _navigateToCurrencyConverter,
        onDeleteTransaction: _deleteTransaction,
      ),
      TransactionsScreen(
        transactions: _transactions,
        currency: _currency,
        onAddTransaction: _openAddTransactionModal,
        onEditTransaction: _openEditTransactionModal,
        onDeleteTransaction: _deleteTransaction,
      ),
      AnalyticsScreen(
        transactions: _transactions,
        budgets: _budgets,
        currency: _currency,
        onOpenBudgets: _navigateToBudgets,
      ),
      SettingsScreen(
        currentCurrency: _currency,
        currentThemeMode: widget.currentThemeMode == ThemeMode.dark ? 'dark' : 'light',
        onCurrencyChanged: _changeCurrency,
        onThemeModeChanged: _changeTheme,
        onResetSampleData: _resetSampleData,
        onClearAllTransactions: _clearAllTransactions,
        onOpenBudgets: _navigateToBudgets,
        onOpenCurrencyConverter: _navigateToCurrencyConverter,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionModal,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.donut_large_outlined),
            selectedIcon: Icon(Icons.donut_large),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
