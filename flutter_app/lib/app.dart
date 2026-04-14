import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/routes.dart';
import 'core/routes/routes_names.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inventory Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: RoutesName.getSplashPage,
      getPages: AppRoutes.routes,
    );
  }
}
