import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ok', () {
    test(
      '''
      GIVEN a repository call that succeeded with the value 1
      WHEN its result is created with Result.ok
      THEN the result is an Ok
      AND it carries the value 1''',
      () {
        // given
        const tValue = 1;
        // when
        const result = Result.ok(tValue);
        // then
        expect(
          result,
          isA<Ok<int>>().having((ok) => ok.value, 'value', tValue),
        );
      },
    );
  });

  group('error', () {
    test(
      '''
      GIVEN a repository call that failed with a server failure
      WHEN its result is created with Result.error
      THEN the result is an Error
      AND it carries the server failure''',
      () {
        // given
        final tFailure = ServerFailure(StateError('server error'));
        // when
        final result = Result<int>.error(tFailure);
        // then
        expect(
          result,
          isA<Error<int>>().having(
            (error) => error.failure,
            'failure',
            tFailure,
          ),
        );
      },
    );
  });
}
