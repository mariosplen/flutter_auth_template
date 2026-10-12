import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tCause = Exception('connection refused');
  final tOtherCause = Exception('connection timed out');

  group('ServerFailure', () {
    test(
      '''
      GIVEN an error that was thrown while talking to the server
      WHEN a ServerFailure is created from that error
      THEN the failure is a Failure that can be thrown as an Exception
      AND it keeps the original error as its cause''',
      () {
        // given
        final cause = tCause;

        // when
        final failure = ServerFailure(cause);

        // then
        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.cause, same(tCause));
      },
    );

    test(
      '''
      GIVEN two ServerFailures that were created from the same cause
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = ServerFailure(tCause);
        final second = ServerFailure(tCause);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two ServerFailures that were created from different causes
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = ServerFailure(tCause);
        final second = ServerFailure(tOtherCause);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  group('GenericFailure', () {
    test(
      '''
      GIVEN an unexpected error that nobody planned for
      WHEN a GenericFailure is created from that error
      THEN the failure is a Failure that can be thrown as an Exception
      AND it keeps the original error as its cause''',
      () {
        // given
        final cause = tCause;

        // when
        final failure = GenericFailure(cause);

        // then
        expect(failure, isA<Failure>());
        expect(failure, isA<Exception>());
        expect(failure.cause, same(tCause));
      },
    );

    test(
      '''
      GIVEN two GenericFailures that were created from the same cause
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = GenericFailure(tCause);
        final second = GenericFailure(tCause);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two GenericFailures that were created from different causes
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = GenericFailure(tCause);
        final second = GenericFailure(tOtherCause);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  test(
    '''
    GIVEN a ServerFailure and a GenericFailure that share the same cause
    WHEN they are compared
    THEN they are not equal, because the kind of failure matters too''',
    () {
      // given
      final Failure serverFailure = ServerFailure(tCause);
      final Failure genericFailure = GenericFailure(tCause);

      // when
      final areEqual = serverFailure == genericFailure;

      // then
      expect(areEqual, isFalse);
    },
  );
}
