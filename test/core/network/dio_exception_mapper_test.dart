import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/network/dio_exception_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DioException buildDioException(DioExceptionType type) => DioException(
    requestOptions: RequestOptions(path: '/'),
    type: type,
  );

  group('toFailure', () {
    test(
      '''
      GIVEN the device is offline, so a request fails with a connection error
      WHEN the DioException is turned into a failure
      THEN a network failure is returned
      AND its cause is the DioException''',
      () {
        // given
        final tError = buildDioException(.connectionError);
        // when
        final result = tError.toFailure();
        // then
        expect(result, NetworkFailure(tError));
      },
    );

    test(
      '''
      GIVEN the server takes too long to answer, so a request times out
      WHEN the DioException is turned into a failure
      THEN a network failure is returned''',
      () {
        // given
        final tError = buildDioException(.receiveTimeout);
        // when
        final result = tError.toFailure();
        // then
        expect(result, NetworkFailure(tError));
      },
    );

    test(
      '''
      GIVEN the server answers a request with an error status
      WHEN the DioException is turned into a failure
      THEN a server failure is returned
      AND its cause is the DioException''',
      () {
        // given
        final tError = buildDioException(.badResponse);
        // when
        final result = tError.toFailure();
        // then
        expect(result, ServerFailure(tError));
      },
    );
  });
}
