import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_navigation_screen.dart';
import 'services/storage_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for modern status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Load saved theme preference
  final savedTheme = await StorageService.getThemeMode();
  final initialMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  runApp(SpendWiseApp(initialThemeMode: initialMode));
}

/// Root Application Widget
class SpendWiseApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const SpendWiseApp({super.key, required this.initialThemeMode});

  @override
  State<SpendWiseApp> createState() => _SpendWiseAppState();
}

class _SpendWiseAppState extends State<SpendWiseApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise – Personal Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MainNavigationScreen(
        onThemeChanged: _updateThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

