import 'package:flutter/material.dart';
import '../models/exchange_rate_model.dart';
import '../services/currency_service.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';

/// Live currency converter screen with live API fetching, error handling, and conversion matrix.
class CurrencyConverterScreen extends StatefulWidget {
  final String initialCurrency;

  const CurrencyConverterScreen({
    super.key,
    this.initialCurrency = 'USD',
  });

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController(text: '100');

  final List<String> _supportedCurrencies = ['INR', 'USD', 'EUR', 'GBP'];
  late String _fromCurrency;
  late String _toCurrency;

  ExchangeRateData? _exchangeData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsingFallback = false;

  @override
  void initState() {
    super.initState();
    _fromCurrency = widget.initialCurrency.toUpperCase();
    if (!_supportedCurrencies.contains(_fromCurrency)) {
      _fromCurrency = 'USD';
    }
    _toCurrency = _fromCurrency == 'INR' ? 'USD' : 'INR';

    _fetchRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await CurrencyService.fetchExchangeRates();
      setState(() {
        _exchangeData = data;
        _isLoading = false;
        _isUsingFallback = (data.lastUpdated.difference(DateTime.now()).inHours.abs() > 48);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not fetch live rates. Using saved offline rates.';
        _exchangeData = CurrencyService.offlineFallbackData;
        _isUsingFallback = true;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inputAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    double convertedAmount = 0.0;
    double unitRate = 1.0;

    if (_exchangeData != null) {
      convertedAmount = _exchangeData!.convert(inputAmount, _fromCurrency, _toCurrency);
      unitRate = _exchangeData!.convert(1.0, _fromCurrency, _toCurrency);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Rates',
            onPressed: _isLoading ? null : _fetchRates,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status or Error Banner
            if (_errorMessage != null || _isUsingFallback)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage ?? 'Working in offline mode with cached rates.',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _fetchRates,
                      child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            // Main Converter Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Input
                  Text(
                    'Amount to Convert',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Text(
                          CurrencyHelper.getSymbol(_fromCurrency),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      hintText: '0.00',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Currency Selectors with Swap Button
                  Row(
                    children: [
                      // From Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildCurrencyDropdown(_fromCurrency, isDark, (val) {
                              if (val != null) setState(() => _fromCurrency = val);
                            }),
                          ],
                        ),
                      ),

                      // Swap Button
                      Padding(
                        padding: const EdgeInsets.only(top: 18, left: 8, right: 8),
                        child: IconButton.filledTonal(
                          icon: const Icon(Icons.swap_horiz, size: 22),
                          onPressed: _swapCurrencies,
                          tooltip: 'Swap Currencies',
                        ),
                      ),

                      // To Selector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildCurrencyDropdown(_toCurrency, isDark, (val) {
                              if (val != null) setState(() => _toCurrency = val);
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 36),

                  // Converted Result Display
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    Text(
                      'Converted Amount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyHelper.format(convertedAmount, _toCurrency),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Exchange rate details
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 6),
                        Text(
                          '1 $_fromCurrency = ${unitRate.toStringAsFixed(4)} $_toCurrency',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Exchange Rates Table
            Text(
              'Supported Currencies Matrix (Base: 1 USD)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                children: _supportedCurrencies.map((code) {
                  final rate = _exchangeData?.convert(1.0, 'USD', code) ?? 1.0;
                  final isLast = code == _supportedCurrencies.last;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  CurrencyHelper.getSymbol(code),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      CurrencyHelper.currencyNames[code] ?? code,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              rate.toStringAsFixed(code == 'INR' ? 2 : 4),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(String value, bool isDark, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          items: _supportedCurrencies.map((c) {
            return DropdownMenuItem<String>(
              value: c,
              child: Text(
                '$c (${CurrencyHelper.getSymbol(c)})',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
