import 'package:dio/dio.dart';

import '../datasources/auth_api.dart';
import '../datasources/session_storage.dart';

class AuthInterceptor({
  required final Dio _dio,
  required final AuthApi _authApi,
  required final SessionStorage _sessionStorage,
  required final void Function() _onSessionExpired,
}) extends Interceptor {
  static const _retriedKey = 'retried';

  Future<void>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = _sessionStorage.session;
    if (session != null && options.extra[requiresAuthKey] != false) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final session = _sessionStorage.session;
    if (!_isUnauthorized(err) ||
        session == null ||
        options.extra[requiresAuthKey] == false ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final sentWithCurrentToken =
        options.headers['Authorization'] == 'Bearer ${session.accessToken}';
    if (sentWithCurrentToken) {
      try {
        await (_refreshing ??= _refresh(session.refreshToken)
            .whenComplete(() => _refreshing = null));
      } on DioException catch (error) {
        return handler.next(error);
      }
    }

    options.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch(options));
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  Future<void> _refresh(String refreshToken) async {
    bool isStillCurrent() =>
        _sessionStorage.session?.refreshToken == refreshToken;
    try {
      final fresh = await _authApi.refreshSession(refreshToken);
      if (isStillCurrent()) await _sessionStorage.save(fresh);
    } on DioException catch (error) {
      if (_isRejected(error) && isStillCurrent()) {
        try {
          await _sessionStorage.clear();
        } finally {
          _onSessionExpired();
        }
      }
      rethrow;
    }
  }

  static bool _isUnauthorized(DioException error) => switch (error.response) {
    Response(statusCode: 401) => true,
    // Supabase Auth answers an expired access token with 403 bad_jwt
    Response(statusCode: 403, data: {'error_code': 'bad_jwt'}) => true,
    _ => false,
  };

  static bool _isRejected(DioException error) =>
      switch (error.response?.statusCode) {
        null || 408 || 429 => false,
        final int statusCode => statusCode >= 400 && statusCode < 500,
      };
}
