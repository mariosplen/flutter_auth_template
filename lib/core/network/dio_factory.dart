import 'package:dio/dio.dart';

/// Creates the Dio client for Supabase. The URL and key default to the
/// values passed with `--dart-define-from-file`.
Dio createDio({
  String url = const String.fromEnvironment('SUPABASE_URL'),
  String publishableKey = const String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  ),
}) {
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
