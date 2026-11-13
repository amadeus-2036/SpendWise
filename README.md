# SpendWise

SpendWise is a personal finance tracker built with Flutter and Material 3. It helps users record income and expenses, manage category budgets, review spending insights, and convert currencies.

## Features

- Dashboard with balance, income, expense, and recent-transaction summaries
- Transaction history with search, filters, and swipe-to-delete
- Monthly category budgets with progress and limit alerts
- Spending analytics with category and monthly trend charts
- Currency conversion for INR, USD, EUR, and GBP
- Local persistence for transactions, budgets, and preferences
- Light and dark themes

## Tech Stack

- Flutter and Dart
- Material 3
- `shared_preferences` for local storage
- `fl_chart` for analytics charts
- `http` for exchange-rate requests

## Getting Started

### Prerequisites

Install Flutter and verify your environment:

```bash
flutter doctor
```

### Run locally

```bash
flutter pub get
flutter run -d chrome
```

You can replace `chrome` with another available Flutter target, such as `windows` or an emulator.

## Project Structure

```text
lib/
├── models/      # Application data models
├── screens/     # Main application screens
├── services/    # Storage, sample data, and currency API services
├── utils/       # Theme, color, formatting, and currency helpers
├── widgets/     # Reusable UI components
└── main.dart    # Application entry point
```

## Data

SpendWise stores financial data locally on the device. Currency rates are retrieved from a public exchange-rate API, with fallback values available when offline.
