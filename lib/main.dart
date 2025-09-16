import 'package:expense_tracker_v02/models/recurring_expense.dart';
import 'package:expense_tracker_v02/providers/settings_provider.dart';
import 'package:expense_tracker_v02/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

import 'adapters/icon_adapter.dart';
import 'models/expense.dart';
import 'models/expense_category.dart';
import 'providers/expense_provider.dart';
import 'config/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(IconAdapter());
  Hive.registerAdapter(RecurringExpenseAdapter());

   // ✅ Initialize SettingsProvider with Hive
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _authenticated = false;
  bool _biometricAvailable = true; // toggleable later via settings
  

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    try {
      if (_biometricAvailable) {
        final didAuthenticate = await _localAuth.authenticate(
          localizedReason: "Authenticate to access Expense Tracker",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        setState(() => _authenticated = didAuthenticate);
      } else {
        setState(() => _authenticated = true);
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
      setState(() => _authenticated = true); // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              "🔒 Authentication Required",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );
    }

    

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Expense Tracker',
            theme: themeProvider.themeData,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
