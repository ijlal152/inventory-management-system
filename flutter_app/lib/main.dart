import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/dependency_injection.dart';
import 'data/datasources/local/product_local_datasource.dart';
import 'data/models/product_model.dart';
import 'services/background_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(SyncActionAdapter());

  // Initialize local data source
  final localDataSource = ProductLocalDataSourceImpl();
  await localDataSource.init();

  // Initialize Secure Storage and SharedPreferences
  const secureStorage = FlutterSecureStorage();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Setup dependencies
  await DependencyInjection.init(
      localDataSource, secureStorage, sharedPreferences);

  // Initialize background sync
  await BackgroundSyncService.initialize();

  runApp(const MyApp());
}
