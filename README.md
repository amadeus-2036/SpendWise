# SpendWise – Personal Finance Tracker

SpendWise is a functional, visually polished personal finance and budget tracker built with **Flutter**, **Dart**, and **Material 3**. It features a modern fintech aesthetic (navy/slate tones, emerald accents, rounded summary cards, and responsive layouts) with clean, beginner-friendly architecture using `StatefulWidget` and `setState`.

---

## 🌟 Highlights & Key Features

### 1. Dashboard
- **Total Net Balance, Income & Expenses**: Hero gradient card displaying live calculated metrics.
- **Quick Action Row**: Fast 1-tap buttons to add transactions, check budgets, or open the currency converter.
- **Monthly Budget Utilization Banner**: Real-time progress bar tracking overall monthly spending against the cumulative budget limit.
- **Recent Transactions**: Shows latest entries with quick access to the full transaction history.

### 2. Transactions
- **Add Income & Expense**: Modal bottom sheet with type toggle (Expense vs Income), amount validation, category selection, date picker, and optional notes.
- **Transaction History**: Displays category icons, colored amounts (`+` green for income, `-` red for expense), and friendly date tags.
- **Filters & Search**: Filter by type (*All*, *Expenses Only*, *Income Only*), filter by category chips, and live text search.
- **Swipe-to-Delete**: Dismissible swipe-to-delete with confirmation modal and "Undo" snackbar.

### 3. Analytics
- **Category Donut Chart (`fl_chart`)**: Interactive touch-enabled pie chart showing proportional category breakdown with percentage labels and center total.
- **Monthly Spending Trends Bar Chart (`fl_chart`)**: Visualizes monthly expense volume across the past 6 months with touch tooltips.
- **Budget Health & Savings Rate**: Calculates savings rate percentage (`(Income - Expense) / Income`) and highlights the month's highest spending category.

### 4. Budgets
- **Category-Specific Limits**: Set monthly targets for Food, Shopping, Utilities, Entertainment, and more.
- **Utilization Gauges**: Animated progress bars showing spent vs limit and remaining funds.
- **Warning System**: Automatic badges for *On Track* (<80%), *Near Limit* (80%–100%), and *Exceeded* (>100% with warning alert banner).

### 5. Live Currency Converter
- **Live Exchange Rate API**: Fetches real-time exchange rates from a public, free REST API (`open.er-api.com`).
- **Supported Currencies**: **INR (₹)**, **USD ($)**, **EUR (€)**, and **GBP (£)**.
- **Resilient Network Handling**: Smooth loading indicator, error handling with Retry button, and offline fallback rates.
- **Exchange Matrix**: Quick reference matrix comparing all 4 currencies against the base rate.

### 6. Persistence & Preferences
- **Local Storage (`shared_preferences`)**: Auto-saves all transactions and budgets locally.
- **Initial Sample Data**: Pre-loads realistic sample transactions on first launch.
- **Settings**: Change default currency (INR, USD, EUR, GBP), toggle Light/Dark mode, reset to sample data, or wipe transactions.

---

## 📁 Project Structure

```text
SpendWise/
├── pubspec.yaml                 # Project dependencies & Flutter metadata
├── analysis_options.yaml        # Flutter linter configuration
├── web/                         # Web support files (index.html, manifest.json)
└── lib/
    ├── main.dart                # Application entrypoint & ThemeMode switching
    ├── models/
    │   ├── app_category.dart    # Categories, icons, and theme colors
    │   ├── budget_item.dart     # Monthly budget limit data model
    │   ├── exchange_rate_model.dart # Currency conversion data model
    │   └── transaction_item.dart    # Transaction model with JSON serialization
    ├── utils/
    │   ├── app_colors.dart      # Fintech color palette & card gradients
    │   ├── app_theme.dart       # Material 3 light & dark theme definitions
    │   ├── currency_helper.dart # Currency symbols & number formatting
    │   └── date_formatter.dart  # Date and month formatting utilities
    ├── services/
    │   ├── currency_service.dart     # HTTP client for free exchange-rate API
    │   ├── sample_data_service.dart  # Realistic starter data on first run
    │   └── storage_service.dart      # SharedPreferences persistence layer
    ├── widgets/
    │   ├── add_transaction_modal.dart # Bottom sheet for entering new transactions
    │   ├── budget_progress_card.dart  # Progress indicator card for category budgets
    │   ├── category_donut_chart.dart  # Interactive donut chart (fl_chart)
    │   ├── edit_budget_modal.dart     # Dialog to update category budget limit
    │   ├── empty_state_view.dart      # Empty state illustration & call-to-action
    │   ├── monthly_bar_chart.dart     # Monthly spending bar chart (fl_chart)
    │   ├── summary_card.dart          # Hero balance & income/expense gradient card
    │   └── transaction_tile.dart      # Dismissible list tile for transactions
    └── screens/
        ├── main_navigation_screen.dart # 4-tab bottom navigation coordinator
        ├── dashboard_screen.dart       # Dashboard overview
        ├── transactions_screen.dart    # Searchable & filterable history
        ├── analytics_screen.dart       # Charts & financial analytics
        ├── budgets_screen.dart         # Category budget manager
        ├── currency_converter_screen.dart # Live exchange rate calculator
        └── settings_screen.dart        # Preferences, theme & data controls
```

---

## 🚀 How to Run the Project

### Prerequisites
Make sure Flutter is installed on your computer. If you have not yet installed Flutter:
1. Download Flutter SDK for Windows from [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows).
2. Extract the zip to `C:\src\flutter` (or another folder of your choice).
3. Add `C:\src\flutter\bin` to your Windows User `Path` environment variable.
4. Verify by opening a new terminal and running:
   ```bash
   flutter doctor
   ```

### Running SpendWise
From inside the `SpendWise` project folder:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run the application (choose your target device: Chrome, Windows desktop, or emulator)
flutter run -d chrome
# or
flutter run -d windows
```

---

## 💡 Beginner-Friendly Architecture Notes

- **No Overcomplicated State Management**: Uses native Flutter `StatefulWidget` and `setState` to make the code straightforward to read, follow, and modify.
- **Clear Separation of Concerns**:
  - `models/`: Pure Dart classes with simple JSON serialization (`toJson` / `fromJson`).
  - `services/`: Encapsulates async storage operations (`storage_service.dart`) and REST API requests (`currency_service.dart`).
  - `widgets/`: Reusable, modular UI components that receive data via parameters and communicate via callbacks.
  - `screens/`: Scaffolded screens for each main view.

