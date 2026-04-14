import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../data/datasources/local/auth_local_datasource.dart';
import '../constants/api_constants.dart';

class AuthenticatedDioClient {
  late final Dio _dio;
  final AuthLocalDataSource _authDataSource;

  AuthenticatedDioClient({
    required AuthLocalDataSource authDataSource,
  }) : _authDataSource = authDataSource {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from local storage and add to headers
          final token = await _authDataSource.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Add pretty logger interceptor for request/response logging
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  Dio get dio => _dio;
}
