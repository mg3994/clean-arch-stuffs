import 'package:logger_service/logger_service.dart';

abstract class NetworkClient {
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters});
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body});
}

class MockNetworkClient implements NetworkClient {
  final LoggerService? logger;
  final Map<String, dynamic> Function(String path, Map<String, dynamic>? body)? postHandler;
  final Map<String, dynamic> Function(String path, Map<String, dynamic>? queryParameters)? getHandler;

  MockNetworkClient({this.logger, this.postHandler, this.getHandler});

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    logger?.info('GET Request -> $path');
    if (getHandler != null) {
      return getHandler!(path, queryParameters);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    logger?.info('POST Request -> $path');
    if (postHandler != null) {
      return postHandler!(path, body);
    }
    return {};
  }
}
