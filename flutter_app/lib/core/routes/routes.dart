import 'package:get/get.dart';

import '../../presentation/controllers/barcode_scanner_controller.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/splash_page.dart';
import '../../presentation/pages/barcode_scanner/barcode_scanner_page.dart';
import '../../presentation/pages/product_form/product_form_page.dart';
import '../../presentation/pages/product_list/product_list_page.dart';
import '../../services/barcode_service.dart';
import 'routes_names.dart';

class AppRoutes {
  static final AppRoutes _sharedInstance = AppRoutes._internal();

  factory AppRoutes() {
    return _sharedInstance;
  }

  AppRoutes._internal();

  static List<GetPage> routes = [
    // Splash
    GetPage(
      name: RoutesName.getSplashPage,
      page: () => const SplashPage(),
      transition: Transition.cupertino,
    ),

    // Authentication
    GetPage(
      name: RoutesName.getLoginPage,
      page: () => const LoginPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: RoutesName.getRegisterPage,
      page: () => const RegisterPage(),
      transition: Transition.cupertino,
    ),

    // Products
    GetPage(
      name: RoutesName.getProductsPage,
      page: () => const ProductListPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: RoutesName.getProductFormPage,
      page: () => const ProductFormPage(),
      transition: Transition.cupertino,
    ),

    // Barcode Scanner
    GetPage(
      name: RoutesName.getBarcodeScannerPage,
      page: () => const BarcodeScannerPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => BarcodeScannerController(
            barcodeService: Get.find<BarcodeService>(),
          ),
        );
      }),
      transition: Transition.cupertino,
    ),
  ];
}
