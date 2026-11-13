import 'package:intl/intl.dart';

/// Helper utility for handling currencies and number formatting.
class CurrencyHelper {
  /// Map of currency codes to symbols
  static const Map<String, String> currencySymbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  /// Map of currency codes to names
  static const Map<String, String> currencyNames = {
    'INR': 'Indian Rupee (₹)',
    'USD': 'US Dollar (\$)',
    'EUR': 'Euro (€)',
    'GBP': 'British Pound (£)',
  };

  /// Get symbol for a given currency code
  static String getSymbol(String code) {
    return currencySymbols[code.toUpperCase()] ?? '\$';
  }

  /// Format an amount into a readable string with currency symbol.
  /// Example: format(12500.5, 'INR') => "₹12,500.50"
  static String format(double amount, String currencyCode, {bool compact = false}) {
    final symbol = getSymbol(currencyCode);
    
    if (compact && amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (compact && amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }

    // Standard number format with commas and two decimals
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${formatter.format(amount)}';
  }

  /// Format without symbol for inputs
  static String formatPlain(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }
}

