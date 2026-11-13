import '../models/transaction_item.dart';
import '../models/budget_item.dart';

/// Provides initial realistic sample data for SpendWise on first launch.
class SampleDataService {
  /// Generate sample transactions spanning the current and previous months
  static List<TransactionItem> getInitialTransactions() {
    final now = DateTime.now();

    DateTime prevMonthDate(int monthsAgo, int day) {
      var year = now.year;
      var month = now.month - monthsAgo;
      while (month <= 0) {
        month += 12;
        year -= 1;
      }
      return DateTime(year, month, day);
    }

    return [
      // --- Current Month Entries ---
      TransactionItem(
        id: 'tx_1',
        title: 'Monthly Tech Salary',
        amount: 4500.00,
        category: 'Salary',
        date: DateTime(now.year, now.month, 1),
        isExpense: false,
        notes: 'Monthly direct deposit from Acme Corp',
      ),
      TransactionItem(
        id: 'tx_2',
        title: 'Apartment Rent & Maintenance',
        amount: 1200.00,
        category: 'Bills & Utilities',
        date: DateTime(now.year, now.month, 2),
        isExpense: true,
        notes: 'Bank transfer for rent',
      ),
      TransactionItem(
        id: 'tx_3',
        title: 'Weekly Grocery Run',
        amount: 142.50,
        category: 'Food & Dining',
        date: DateTime(now.year, now.month, 3),
        isExpense: true,
        notes: 'Supermarket supplies and veggies',
      ),
      TransactionItem(
        id: 'tx_4',
        title: 'Freelance UI/UX Design Project',
        amount: 850.00,
        category: 'Freelance & Side Gig',
        date: DateTime(now.year, now.month, 5),
        isExpense: false,
        notes: 'Mobile app design milestone payment',
      ),
      TransactionItem(
        id: 'tx_5',
        title: 'High-speed Fiber Internet',
        amount: 65.00,
        category: 'Bills & Utilities',
        date: DateTime(now.year, now.month, 6),
        isExpense: true,
        notes: 'Monthly broadband subscription',
      ),
      TransactionItem(
        id: 'tx_6',
        title: 'Fine Dining with Friends',
        amount: 88.00,
        category: 'Food & Dining',
        date: DateTime(now.year, now.month, 7),
        isExpense: true,
        notes: 'Bistro dinner',
      ),
      TransactionItem(
        id: 'tx_7',
        title: 'Gasoline & Fuel',
        amount: 55.00,
        category: 'Transportation',
        date: DateTime(now.year, now.month, 8),
        isExpense: true,
        notes: 'Full tank fuel refill',
      ),
      TransactionItem(
        id: 'tx_8',
        title: 'New Running Shoes',
        amount: 120.00,
        category: 'Shopping',
        date: DateTime(now.year, now.month, 9),
        isExpense: true,
        notes: 'Sport shoes from Nike Store',
      ),
      TransactionItem(
        id: 'tx_9',
        title: 'Netflix & Spotify Family',
        amount: 28.50,
        category: 'Entertainment',
        date: DateTime(now.year, now.month, 10),
        isExpense: true,
        notes: 'Streaming services renewal',
      ),
      TransactionItem(
        id: 'tx_10',
        title: 'Stock Dividend Payout',
        amount: 115.00,
        category: 'Investments',
        date: DateTime(now.year, now.month, 11),
        isExpense: false,
        notes: 'Quarterly index fund dividend',
      ),
      TransactionItem(
        id: 'tx_11',
        title: 'Pharmacy & Health Vitamins',
        amount: 45.00,
        category: 'Healthcare',
        date: DateTime(now.year, now.month, 11),
        isExpense: true,
        notes: 'Monthly multivitamin supplements',
      ),

      // --- Previous Month Entries (for historical Bar Chart trends) ---
      TransactionItem(
        id: 'tx_prev_1',
        title: 'Previous Month Rent',
        amount: 1200.00,
        category: 'Bills & Utilities',
        date: prevMonthDate(1, 2),
        isExpense: true,
      ),
      TransactionItem(
        id: 'tx_prev_2',
        title: 'Previous Month Groceries',
        amount: 320.00,
        category: 'Food & Dining',
        date: prevMonthDate(1, 14),
        isExpense: true,
      ),
      TransactionItem(
        id: 'tx_prev_3',
        title: 'Electronics & Gadgets',
        amount: 280.00,
        category: 'Shopping',
        date: prevMonthDate(1, 20),
        isExpense: true,
      ),
      TransactionItem(
        id: 'tx_prev_4',
        title: 'Weekend Getaway Hotel',
        amount: 210.00,
        category: 'Entertainment',
        date: prevMonthDate(1, 25),
        isExpense: true,
      ),

      // --- 2 Months Ago Entries ---
      TransactionItem(
        id: 'tx_prev2_1',
        title: 'Rent Payment',
        amount: 1200.00,
        category: 'Bills & Utilities',
        date: prevMonthDate(2, 2),
        isExpense: true,
      ),
      TransactionItem(
        id: 'tx_prev2_2',
        title: 'Quarterly Car Service',
        amount: 185.00,
        category: 'Transportation',
        date: prevMonthDate(2, 10),
        isExpense: true,
      ),
      TransactionItem(
        id: 'tx_prev2_3',
        title: 'Grocery Superstore',
        amount: 295.00,
        category: 'Food & Dining',
        date: prevMonthDate(2, 18),
        isExpense: true,
      ),
    ];
  }

  /// Generate default budget limits
  static List<BudgetItem> getInitialBudgets() {
    return [
      BudgetItem(category: 'Food & Dining', monthlyLimit: 500.00),
      BudgetItem(category: 'Shopping', monthlyLimit: 300.00),
      BudgetItem(category: 'Bills & Utilities', monthlyLimit: 1400.00),
      BudgetItem(category: 'Transportation', monthlyLimit: 200.00),
      BudgetItem(category: 'Entertainment', monthlyLimit: 150.00),
      BudgetItem(category: 'Healthcare', monthlyLimit: 100.00),
      BudgetItem(category: 'Education', monthlyLimit: 100.00),
    ];
  }
}
