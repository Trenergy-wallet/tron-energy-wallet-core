import 'package:http/http.dart' as http;
import 'package:on_chain/tron/tron.dart';

/// Провайдер для работы с нодой трона
class TronHTTPProvider implements TronServiceProvider {
  /// Провайдер для работы с нодой трона
  TronHTTPProvider({
    required this.url,
    http.Client? client,
    this.defaultRequestTimeout = const Duration(seconds: 30),
    this.authToken,
  }) : client = client ?? http.Client();

  /// Адрес api
  final String url;

  /// Сетевой клиент для взаимодействия
  final http.Client client;

  /// Таймаут для запросов
  final Duration defaultRequestTimeout;

  /// Токен авторизации
  final String? authToken;

  @override
  Future<TronServiceResponse<T>> doRequest<T>(
    TronRequestDetails params, {
    Duration? timeout,
  }) async {
    final response = await client
        .post(
          params.toUri(url),
          headers: {
            if (authToken != null && authToken!.isNotEmpty)
              'Authorization': 'Bearer $authToken',
            ...params.headers,
          },
          body: params.body(),
        )
        .timeout(timeout ?? defaultRequestTimeout);
    return params.toResponse(response.bodyBytes, response.statusCode);
  }
}
