abstract class NetworkClient {
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters});
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body});
}

class MockNetworkClient implements NetworkClient {
  final Map<String, dynamic> Function(String path, Map<String, dynamic>? body)? postHandler;
  final Map<String, dynamic> Function(String path, Map<String, dynamic>? queryParameters)? getHandler;

  MockNetworkClient({this.postHandler, this.getHandler});

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (getHandler != null) {
      return getHandler!(path, queryParameters);
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    if (postHandler != null) {
      return postHandler!(path, body);
    }
    return {};
  }
}
