import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rate_model.dart';

/// Service to fetch live exchange rates from a free, public API.
class CurrencyService {
  static const String _primaryApiUrl = 'https://open.er-api.com/v6/latest/USD';
  static const String _fallbackApiUrl = 'https://api.exchangerate-api.com/v4/latest/USD';

  /// Cached exchange rate data in memory
  static ExchangeRateData? _cachedData;

  /// Default reliable offline fallback rates (USD base)
  static ExchangeRateData get offlineFallbackData => ExchangeRateData(
        baseCurrency: 'USD',
        lastUpdated: DateTime.now(),
        rates: {
          'USD': 1.0,
          'INR': 84.50,
          'EUR': 0.92,
          'GBP': 0.79,
        },
      );

  /// Fetch live exchange rates with timeout and dual-API fallback
  static Future<ExchangeRateData> fetchExchangeRates() async {
    // If cached and fresh (less than 1 hour), return cached
    if (_cachedData != null) {
      final cacheAge = DateTime.now().difference(_cachedData!.lastUpdated);
      if (cacheAge.inMinutes < 60) {
        return _cachedData!;
      }
    }

    try {
      // Attempt primary API
      final response = await http
          .get(Uri.parse(_primaryApiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        _cachedData = ExchangeRateData.fromJson(body);
        return _cachedData!;
      }
    } catch (_) {
      // Primary failed; proceed to secondary fallback API
    }

    try {
      final fallbackResponse = await http
          .get(Uri.parse(_fallbackApiUrl))
          .timeout(const Duration(seconds: 8));

      if (fallbackResponse.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(fallbackResponse.body);
        _cachedData = ExchangeRateData.fromJson(body);
        return _cachedData!;
      }
    } catch (_) {
      // Both network calls failed
    }

    // Return cached data if available, otherwise return realistic offline fallback data
    return _cachedData ?? offlineFallbackData;
  }
}

