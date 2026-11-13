import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';

/// Settings screen for configuring default currency, theme mode, and data management.
class SettingsScreen extends StatelessWidget {
  final String currentCurrency;
  final String currentThemeMode;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onThemeModeChanged;
  final VoidCallback onResetSampleData;
  final VoidCallback onClearAllTransactions;
  final VoidCallback onOpenBudgets;
  final VoidCallback onOpenCurrencyConverter;

  const SettingsScreen({
    super.key,
    required this.currentCurrency,
    required this.currentThemeMode,
    required this.onCurrencyChanged,
    required this.onThemeModeChanged,
    required this.onResetSampleData,
    required this.onClearAllTransactions,
    required this.onOpenBudgets,
    required this.onOpenCurrencyConverter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Preferences
          _buildSectionHeader('Preferences', isDark),
          Container(
            decoration: _boxDecoration(isDark),
            child: Column(
              children: [
                // Default Currency ListTile
                ListTile(
                  leading: const Icon(Icons.monetization_on_outlined, color: AppColors.primaryLight),
                  title: const Text('Default Currency'),
                  subtitle: Text(CurrencyHelper.currencyNames[currentCurrency] ?? currentCurrency),
                  trailing: DropdownButton<String>(
                    value: currentCurrency,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                      DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                    ],
                    onChanged: (val) {
                      if (val != null) onCurrencyChanged(val);
                    },
                  ),
                ),
                Divider(height: 1, color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),

                // Theme Mode Switch
                SwitchListTile(
                  secondary: Icon(
                    currentThemeMode == 'dark' ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: AppColors.primaryLight,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(currentThemeMode == 'dark' ? 'Dark theme enabled' : 'Light theme enabled'),
                  value: currentThemeMode == 'dark',
                  onChanged: (val) {
                    onThemeModeChanged(val ? 'dark' : 'light');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Financial Tools
          _buildSectionHeader('Financial Tools', isDark),
          Container(
            decoration: _boxDecoration(isDark),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pie_chart_outline, color: AppColors.accent),
                  title: const Text('Monthly Budgets'),
                  subtitle: const Text('Configure category limits & warning thresholds'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenBudgets,
                ),
                Divider(height: 1, color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: Color(0xFF0EA5E9)),
                  title: const Text('Live Currency Converter'),
                  subtitle: const Text('Fetch live rates for INR, USD, EUR, GBP'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: onOpenCurrencyConverter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Data Management
          _buildSectionHeader('Data Management', isDark),
          Container(
            decoration: _boxDecoration(isDark),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restore_page_outlined, color: AppColors.primaryLight),
                  title: const Text('Reset to Sample Data'),
                  subtitle: const Text('Restore realistic sample transactions and default budgets'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset to Sample Data?'),
                        content: const Text(
                          'This will replace your current entries with realistic starter transactions and budgets.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              onResetSampleData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reset to sample data successfully.')),
                              );
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: AppColors.expense),
                  title: const Text('Clear All Transactions', style: TextStyle(color: AppColors.expense)),
                  subtitle: const Text('Permanently delete all recorded transactions'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear All Transactions?'),
                        content: const Text('Are you sure? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              onClearAllTransactions();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('All transactions deleted.')),
                              );
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 4: About SpendWise
          _buildSectionHeader('About', isDark),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _boxDecoration(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.wallet, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SpendWise',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Personal Finance & Budget Tracker',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Built with Flutter, Material 3, fl_chart, SharedPreferences, and Open Exchange Rates API. Designed for clean, elegant, and private expense tracking.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
      ),
    );
  }
}

