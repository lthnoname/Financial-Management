import 'package:flutter/material.dart';
import 'shared/placeholder_page.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Management',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const PlaceholderPage(title: 'Login'),
        '/register': (_) => const PlaceholderPage(title: 'Register'),
        '/verify-otp': (_) =>
            const PlaceholderPage(title: 'Verify OTP'),
        '/forgot-password': (_) =>
            const PlaceholderPage(title: 'Forgot Password'),
        '/reset-password': (_) =>
            const PlaceholderPage(title: 'Reset Password'),
        '/dashboard': (_) =>
            const PlaceholderPage(title: 'Dashboard'),
        '/transactions': (_) =>
            const PlaceholderPage(title: 'Transactions'),
        '/add-transaction': (_) =>
            const PlaceholderPage(title: 'Add Transaction'),
        '/transaction-detail': (_) =>
            const PlaceholderPage(title: 'Transaction Detail'),
      },
    );
  }
}