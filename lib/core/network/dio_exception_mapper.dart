import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';

extension DioExceptionMapper on DioException {
  Failure toFailure() => switch (type) {
    .connectionError ||
    .connectionTimeout ||
    .sendTimeout ||
    .receiveTimeout => NetworkFailure(this),
    _ => ServerFailure(this),
  };
}
