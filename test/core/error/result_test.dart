import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result.ok', () {
    test(
      '''
      GIVEN a value that an operation produced
      WHEN Result.ok is created with that value
      THEN the result is an Ok
      AND the Ok holds the very same value''',
      () {
        // given
        final tValue = ['first', 'second'];

        // when
        final result = Result.ok(tValue);

        // then
        expect(result, isA<Ok<List<String>>>());
        expect((result as Ok<List<String>>).value, same(tValue));
      },
    );
  });

  group('Result.error', () {
    test(
      '''
      GIVEN a failure that stopped an operation
      WHEN Result.error is created with that failure
      THEN the result is an Error
      AND the Error holds the very same failure''',
      () {
        // given
        final tFailure = ServerFailure(Exception('connection refused'));

        // when
        final result = Result<List<String>>.error(tFailure);

        // then
        expect(result, isA<Error<List<String>>>());
        expect((result as Error<List<String>>).failure, same(tFailure));
      },
    );
  });
}
