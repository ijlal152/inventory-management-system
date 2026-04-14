class RoutesName {
  static final RoutesName _sharedInstance = RoutesName._internal();

  factory RoutesName() {
    return _sharedInstance;
  }
  RoutesName._internal();

  // Splash
  static const String getSplashPage = '/splash';

  // Authentication
  static const String getLoginPage = '/login';
  static const String getRegisterPage = '/register';

  // Products
  static const String getProductsPage = '/products';
  static const String getProductFormPage = '/product-form';

  // Barcode Scanner
  static const String getBarcodeScannerPage = '/barcode-scanner';
}
