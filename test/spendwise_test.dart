import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/models/transaction_item.dart';
import 'package:spendwise/models/budget_item.dart';
import 'package:spendwise/models/exchange_rate_model.dart';
import 'package:spendwise/utils/currency_helper.dart';

void main() {
  group('Financial Calculations Tests', () {
    test('Calculates total balance, income, and expenses accurately', () {
      final transactions = [
        TransactionItem(
          id: '1',
          title: 'Salary',
          amount: 5000.0,
          category: 'Salary',
          date: DateTime(2026, 11, 1),
          isExpense: false,
        ),
        TransactionItem(
          id: '2',
          title: 'Freelance',
          amount: 1200.0,
          category: 'Freelance & Side Gig',
          date: DateTime(2026, 11, 3),
          isExpense: false,
        ),
        TransactionItem(
          id: '3',
          title: 'Rent',
          amount: 1500.0,
          category: 'Bills & Utilities',
          date: DateTime(2026, 11, 2),
          isExpense: true,
        ),
        TransactionItem(
          id: '4',
          title: 'Groceries',
          amount: 350.50,
          category: 'Food & Dining',
          date: DateTime(2026, 11, 4),
          isExpense: true,
        ),
      ];

      double income = 0.0;
      double expense = 0.0;

      for (final tx in transactions) {
        if (tx.isExpense) {
          expense += tx.amount;
        } else {
          income += tx.amount;
        }
      }

      final balance = income - expense;

      expect(income, equals(6200.0));
      expect(expense, equals(1850.50));
      expect(balance, equals(4349.50));
    });

    test('Budget utilization and warnings calculate correctly', () {
      final budget = BudgetItem(category: 'Food & Dining', monthlyLimit: 500.0);

      // Under 80% (On Track)
      double spent1 = 300.0;
      double ratio1 = spent1 / budget.monthlyLimit;
      expect(ratio1 < 0.8, isTrue);

      // Between 80% and 100% (Warning)
      double spent2 = 450.0;
      double ratio2 = spent2 / budget.monthlyLimit;
      expect(ratio2 >= 0.8 && ratio2 <= 1.0, isTrue);

      // Exceeded (>100%)
      double spent3 = 550.0;
      expect(spent3 > budget.monthlyLimit, isTrue);
      expect(spent3 - budget.monthlyLimit, equals(50.0));
    });
  });

  group('Currency Conversion Math Tests', () {
    test('Converts correctly across supported currencies', () {
      final exchangeData = ExchangeRateData(
        baseCurrency: 'USD',
        lastUpdated: DateTime.now(),
        rates: {
          'USD': 1.0,
          'INR': 84.50,
          'EUR': 0.92,
          'GBP': 0.79,
        },
      );

      // 100 USD to INR
      final inr = exchangeData.convert(100.0, 'USD', 'INR');
      expect(inr, equals(8450.0));

      // Same currency conversion
      expect(exchangeData.convert(50.0, 'USD', 'USD'), equals(50.0));
      expect(exchangeData.convert(1000.0, 'INR', 'INR'), equals(1000.0));

      // 84.5 INR to USD
      final usdFromInr = exchangeData.convert(84.50, 'INR', 'USD');
      expect(usdFromInr, closeTo(1.0, 0.001));

      // Cross-currency conversion: EUR to GBP
      final gbpFromEur = exchangeData.convert(100.0, 'EUR', 'GBP');
      // (100 / 0.92) * 0.79 = 85.869...
      expect(gbpFromEur, closeTo(85.87, 0.01));
    });

    test('Currency helper formats numbers and symbols properly', () {
      expect(CurrencyHelper.getSymbol('INR'), equals('₹'));
      expect(CurrencyHelper.getSymbol('USD'), equals('\$'));
      expect(CurrencyHelper.getSymbol('EUR'), equals('€'));
      expect(CurrencyHelper.getSymbol('GBP'), equals('£'));

      final formattedUsd = CurrencyHelper.format(1250.75, 'USD');
      expect(formattedUsd, equals('\$1,250.75'));

      final formattedInr = CurrencyHelper.format(12500.0, 'INR');
      expect(formattedInr, equals('₹12,500.00'));
    });
  });

  group('JSON Serialization & Persistence Tests', () {
    test('TransactionItem serializes and deserializes cleanly', () {
      final tx = TransactionItem(
        id: 'tx_test_101',
        title: 'Office Coffee',
        amount: 4.75,
        category: 'Food & Dining',
        date: DateTime(2026, 11, 12, 9, 30),
        isExpense: true,
        notes: 'Espresso with colleague',
      );

      final json = tx.toJson();
      final deserialized = TransactionItem.fromJson(json);

      expect(deserialized.id, equals(tx.id));
      expect(deserialized.title, equals(tx.title));
      expect(deserialized.amount, equals(tx.amount));
      expect(deserialized.category, equals(tx.category));
      expect(deserialized.isExpense, equals(tx.isExpense));
      expect(deserialized.notes, equals(tx.notes));
    });

    test('BudgetItem serializes and deserializes cleanly', () {
      final budget = BudgetItem(category: 'Shopping', monthlyLimit: 400.0);
      final json = budget.toJson();
      final deserialized = BudgetItem.fromJson(json);

      expect(deserialized.category, equals('Shopping'));
      expect(deserialized.monthlyLimit, equals(400.0));
    });
  });

  group('Filtering and Search Logic Tests', () {
    final list = [
      TransactionItem(
        id: '1',
        title: 'Nike Shoes',
        amount: 120.0,
        category: 'Shopping',
        date: DateTime(2026, 11, 10),
        isExpense: true,
        notes: 'Running sneakers',
      ),
      TransactionItem(
        id: '2',
        title: 'Freelance Project',
        amount: 800.0,
        category: 'Freelance & Side Gig',
        date: DateTime(2026, 11, 9),
        isExpense: false,
      ),
      TransactionItem(
        id: '3',
        title: 'Grocery Store',
        amount: 55.0,
        category: 'Food & Dining',
        date: DateTime(2026, 11, 8),
        isExpense: true,
      ),
    ];

    test('Filter by expense only', () {
      final expenses = list.where((tx) => tx.isExpense).toList();
      expect(expenses.length, equals(2));
    });

    test('Filter by category', () {
      final shopping = list.where((tx) => tx.category == 'Shopping').toList();
      expect(shopping.length, equals(1));
      expect(shopping.first.title, equals('Nike Shoes'));
    });

    test('Search by query in title or note', () {
      final query = 'sneakers';
      final results = list.where((tx) {
        return tx.title.toLowerCase().contains(query) ||
            (tx.notes?.toLowerCase().contains(query) ?? false);
      }).toList();

      expect(results.length, equals(1));
      expect(results.first.title, equals('Nike Shoes'));
    });
  });
}

