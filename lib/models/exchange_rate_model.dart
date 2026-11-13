/// Represents currency conversion rates from the exchange-rate API.
class ExchangeRateData {
  final String baseCurrency;
  final DateTime lastUpdated;
  final Map<String, double> rates;

  ExchangeRateData({
    required this.baseCurrency,
    required this.lastUpdated,
    required this.rates,
  });

  /// Factory constructor to parse response from open.er-api.com or fallback API
  factory ExchangeRateData.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>? ?? {};
    final parsedRates = <String, double>{};

    rawRates.forEach((key, value) {
      if (value is num) {
        parsedRates[key.toUpperCase()] = value.toDouble();
      }
    });

    DateTime updated = DateTime.now();
    try {
      if (json['time_last_update_unix'] != null) {
        final unixSec = (json['time_last_update_unix'] as num).toInt();
        updated = DateTime.fromMillisecondsSinceEpoch(unixSec * 1000);
      } else if (json['time_last_update_utc'] != null) {
        updated = DateTime.tryParse(json['time_last_update_utc'].toString()) ?? DateTime.now();
      } else if (json['date'] != null) {
        updated = DateTime.tryParse(json['date'].toString()) ?? DateTime.now();
      }
    } catch (_) {
      updated = DateTime.now();
    }

    return ExchangeRateData(
      baseCurrency: (json['base_code'] ?? json['base'] ?? 'USD').toString().toUpperCase(),
      lastUpdated: updated,
      rates: parsedRates,
    );
  }

  /// Convert an amount from fromCurrency to toCurrency
  double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency.toUpperCase() == toCurrency.toUpperCase()) return amount;

    final fromRate = rates[fromCurrency.toUpperCase()] ?? 1.0;
    final toRate = rates[toCurrency.toUpperCase()] ?? 1.0;

    if (fromRate == 0) return 0.0;
    // Amount in base currency = amount / fromRate
    // Amount in target currency = (amount / fromRate) * toRate
    return (amount / fromRate) * toRate;
  }
}
