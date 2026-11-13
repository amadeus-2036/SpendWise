import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_item.dart';
import '../utils/app_colors.dart';
import '../utils/currency_helper.dart';
import '../utils/date_formatter.dart';

/// Monthly spending bar chart displaying past 6 months of expense trends.
class MonthlyBarChart extends StatefulWidget {
  final List<TransactionItem> transactions;
  final String currency;

  const MonthlyBarChart({
    super.key,
    required this.transactions,
    required this.currency,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  int _touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build the past 6 months keys (e.g. "2026-6", "2026-7", etc.)
    final now = DateTime.now();
    final List<DateTime> months = [];
    for (int i = 5; i >= 0; i--) {
      // Calculate month offset
      var year = now.year;
      var month = now.month - i;
      while (month <= 0) {
        month += 12;
        year -= 1;
      }
      months.add(DateTime(year, month, 1));
    }

    // Aggregate monthly expenses
    final Map<String, double> monthlySums = {};
    for (final m in months) {
      monthlySums['${m.year}-${m.month}'] = 0.0;
    }

    for (final tx in widget.transactions) {
      if (tx.isExpense) {
        final key = '${tx.date.year}-${tx.date.month}';
        if (monthlySums.containsKey(key)) {
          monthlySums[key] = (monthlySums[key] ?? 0.0) + tx.amount;
        }
      }
    }

    // Find maximum value to normalize chart height
    double maxVal = 0.0;
    for (final val in monthlySums.values) {
      if (val > maxVal) maxVal = val;
    }
    if (maxVal == 0) maxVal = 100.0; // fallback scale

    // Build bar groups
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < months.length; i++) {
      final m = months[i];
      final key = '${m.year}-${m.month}';
      final value = monthlySums[key] ?? 0.0;
      final isTouched = i == _touchedGroupIndex;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              gradient: LinearGradient(
                colors: isTouched
                    ? [const Color(0xFF2563EB), const Color(0xFF60A5FA)]
                    : [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 22,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxVal * 1.15,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => isDark ? AppColors.darkCard : AppColors.primaryDark,
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (group.x < 0 || group.x >= months.length) return null;
                final monthDate = months[group.x];
                final monthName = DateFormatter.formatMonthShort(monthDate.month);
                return BarTooltipItem(
                  '$monthName\n${CurrencyHelper.format(rod.toY, widget.currency)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
            touchCallback: (FlTouchEvent event, response) {
              if (event.isInterestedForInteractions &&
                  response != null &&
                  response.spot != null) {
                setState(() {
                  _touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                });
              } else {
                setState(() {
                  _touchedGroupIndex = -1;
                });
              }
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value >= maxVal * 1.1) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    CurrencyHelper.format(value, widget.currency, compact: true),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (value % 1 != 0 || index < 0 || index >= months.length) {
                    return const SizedBox.shrink();
                  }
                  final monthDate = months[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormatter.formatMonthShort(monthDate.month),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxVal / 3) > 0 ? (maxVal / 3) : 50,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFE2E8F0),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
