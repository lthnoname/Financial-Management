class AppRoutes {
  AppRoutes._();

  // Root route
  static const String root = '/';

  // Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main app routes
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String addTransaction = '/add-transaction';
  static const String transactionDetail = '/transaction-detail';
}
