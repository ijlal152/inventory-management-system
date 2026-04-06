import 'package:http/http.dart' as http;

import '../../data/datasources/local/auth_local_datasource.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _client;
  final AuthLocalDataSource _authDataSource;

  AuthenticatedHttpClient({
    required http.Client client,
    required AuthLocalDataSource authDataSource,
  }) : _client = client,
       _authDataSource = authDataSource;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Get token from local storage
    final token = await _authDataSource.getToken();

    // Add Content-Type header
    request.headers['Content-Type'] = 'application/json';

    // Add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Send request
    final response = await _client.send(request);

    return response;
  }

  @override
  void close() {
    _client.close();
  }
}
