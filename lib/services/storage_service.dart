import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';
import '../models/budget_item.dart';
import 'sample_data_service.dart';

/// Service responsible for local persistence using SharedPreferences.
class StorageService {
  static const String _keyTransactions = 'spendwise_transactions';
  static const String _keyBudgets = 'spendwise_budgets';
  static const String _keyCurrency = 'spendwise_currency';
  static const String _keyThemeMode = 'spendwise_theme_mode';
  static const String _keyInitialized = 'spendwise_is_initialized';

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Load all transactions. Pre-populates sample data on first run.
  static Future<List<TransactionItem>> loadTransactions() async {
    final prefs = await _instance;
    final isInitialized = prefs.getBool(_keyInitialized) ?? false;

    if (!isInitialized) {
      // First time launch: populate sample transactions & budgets
      final sampleTxs = SampleDataService.getInitialTransactions();
      final sampleBudgets = SampleDataService.getInitialBudgets();
      await saveTransactions(sampleTxs);
      await saveBudgets(sampleBudgets);
      await prefs.setBool(_keyInitialized, true);
      return sampleTxs;
    }

    final jsonString = prefs.getString(_keyTransactions);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => TransactionItem.fromJson(item)).toList();
    } catch (e) {
      // Graceful fallback if parsing corrupted data
      return [];
    }
  }

  /// Save list of transactions to SharedPreferences
  static Future<bool> saveTransactions(List<TransactionItem> transactions) async {
    final prefs = await _instance;
    final encoded = jsonEncode(transactions.map((tx) => tx.toJson()).toList());
    return await prefs.setString(_keyTransactions, encoded);
  }

  /// Load category budgets
  static Future<List<BudgetItem>> loadBudgets() async {
    final prefs = await _instance;
    final jsonString = prefs.getString(_keyBudgets);
    if (jsonString == null || jsonString.isEmpty) {
      return SampleDataService.getInitialBudgets();
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => BudgetItem.fromJson(item)).toList();
    } catch (e) {
      return SampleDataService.getInitialBudgets();
    }
  }

  /// Save category budgets
  static Future<bool> saveBudgets(List<BudgetItem> budgets) async {
    final prefs = await _instance;
    final encoded = jsonEncode(budgets.map((b) => b.toJson()).toList());
    return await prefs.setString(_keyBudgets, encoded);
  }

  /// Get active currency code (defaults to USD or INR)
  static Future<String> getCurrency() async {
    final prefs = await _instance;
    return prefs.getString(_keyCurrency) ?? 'USD';
  }

  /// Set active currency code
  static Future<bool> setCurrency(String code) async {
    final prefs = await _instance;
    return await prefs.setString(_keyCurrency, code);
  }

  /// Get active theme mode ('light', 'dark', or 'system')
  static Future<String> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(_keyThemeMode) ?? 'light';
  }

  /// Set active theme mode
  static Future<bool> setThemeMode(String mode) async {
    final prefs = await _instance;
    return await prefs.setString(_keyThemeMode, mode);
  }

  /// Reset to initial sample data
  static Future<void> resetToSampleData() async {
    final sampleTxs = SampleDataService.getInitialTransactions();
    final sampleBudgets = SampleDataService.getInitialBudgets();
    await saveTransactions(sampleTxs);
    await saveBudgets(sampleBudgets);
  }

  /// Clear all transactions and reset data
  static Future<void> clearAllTransactions() async {
    await saveTransactions([]);
  }
}

