import 'package:dio/dio.dart';

/// Creates the Dio client for Supabase.
Dio createDio({required String url, required String publishableKey}) {
  if (url.isEmpty || publishableKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY is missing. '
      'Run the app with --dart-define-from-file=env/dev.json.',
    );
  }
  return Dio(
    BaseOptions(
      baseUrl: url,
      headers: {'apikey': publishableKey},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
}
