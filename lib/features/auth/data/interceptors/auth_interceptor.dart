import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/app/domain/repositories/session_repository.dart';

import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/mappers/session_response_mapper.dart';

/// Adds the access token to requests. When a request comes back
/// unauthorized, it refreshes the session once and retries the request.
class AuthInterceptor({
  required final Dio _dio,
  required final AuthApi _authApi,
  required final SessionRepository _sessionRepository,
  required final void Function() _onSessionExpired,
}) extends Interceptor {
  // Marks a retried request, so it is never retried twice.
  static const _retriedKey = 'retried';

  // Stores the refresh in progress, shared by requests that fail at the same
  // time.
  Future<void>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = _sessionRepository.session;
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
    final session = _sessionRepository.session;
    if (!_isUnauthorized(err) ||
        session == null ||
        options.extra[requiresAuthKey] == false ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    // If another request already refreshed, this one only needs a retry.
    final sentWithCurrentToken =
        options.headers['Authorization'] == 'Bearer ${session.accessToken}';
    if (sentWithCurrentToken) {
      try {
        await (_refreshing ??= _refresh(session.refreshToken)
            .whenComplete(() => _refreshing = null));
      } on DioException catch (error) {
        return handler.next(error);
      }
      // signed out during the refresh, so there is no token to retry with
      if (_sessionRepository.session == null) return handler.next(err);
    }

    options.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch(options));
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  Future<void> _refresh(String refreshToken) async {
    // False once the session was refreshed or cleared in the meantime.
    bool isStillCurrent() =>
        _sessionRepository.session?.refreshToken == refreshToken;
    try {
      final fresh = await _authApi.refreshSession(refreshToken);
      if (isStillCurrent()) await _sessionRepository.save(fresh.toEntity());
    } on DioException catch (error) {
      // A rejected refresh token means the user is signed out.
      if (_isRejected(error) && isStillCurrent()) {
        try {
          await _sessionRepository.clear();
        } finally {
          _onSessionExpired();
        }
      }
      rethrow;
    }
  }

  static bool _isUnauthorized(DioException error) => switch (error.response) {
    Response(statusCode: 401) => true,
    // Supabase Auth answers an expired access token with 403 bad_jwt.
    Response(statusCode: 403, data: {'error_code': 'bad_jwt'}) => true,
    _ => false,
  };

  /// Whether the server refused the refresh token. Timeouts, rate limits and
  /// network errors never sign the user out.
  static bool _isRejected(DioException error) =>
      switch (error.response?.statusCode) {
        null || 408 || 429 => false,
        final int statusCode => statusCode >= 400 && statusCode < 500,
      };
}
