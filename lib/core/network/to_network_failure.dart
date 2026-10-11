import 'package:dio/dio.dart';

import '../failures/app_failure.dart';

extension DioExceptionAppFailureMapper on DioException {
  NetworkFailure? toNetworkFailure() => switch (type) {
    .connectionTimeout ||
    .sendTimeout ||
    .receiveTimeout ||
    .connectionError => NetworkFailure(this),
    _ => null,
  };
}
