import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServerFailure', () {
    test(
      '''
      GIVEN a server failure created from an error
      WHEN its cause is read
      THEN the cause is that error''',
      () {
        // given
        final tError = StateError('server error');
        final tFailure = ServerFailure(tError);
        // when
        final result = tFailure.cause;
        // then
        expect(result, same(tError));
      },
    );

    test(
      '''
      GIVEN two server failures with the same cause
      WHEN they are compared
      THEN they are equal
      AND they have the same hash code''',
      () {
        // given
        final tError = StateError('server error');
        final tFirst = ServerFailure(tError);
        final tSecond = ServerFailure(tError);
        // when
        final isEqual = tFirst == tSecond;
        final hasSameHashCode = tFirst.hashCode == tSecond.hashCode;
        // then
        expect(isEqual, isTrue);
        expect(hasSameHashCode, isTrue);
      },
    );

    test(
      '''
      GIVEN two server failures with different causes
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        const tFirst = ServerFailure('first cause');
        const tSecond = ServerFailure('second cause');
        // when
        final isEqual = tFirst == tSecond;
        // then
        expect(isEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN a server failure
      WHEN it is thrown
      THEN it can be caught as an Exception''',
      () async {
        // given
        const tFailure = ServerFailure('cause');
        // when
        final result = Future<void>.sync(() => throw tFailure);
        // then
        await expectLater(result, throwsA(isA<Exception>()));
      },
    );
  });

  group('GenericFailure', () {
    test(
      '''
      GIVEN a generic failure and a server failure with the same cause
      WHEN they are compared
      THEN they are not equal, because they are different kinds of failure''',
      () {
        // given
        const tGenericFailure = GenericFailure('cause');
        const tServerFailure = ServerFailure('cause');
        // when
        final isEqual = tGenericFailure == tServerFailure;
        // then
        expect(isEqual, isFalse);
      },
    );
  });
}
