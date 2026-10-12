// The values are created at runtime on purpose: two const values are the very
// same instance, which would not prove that they are compared by value.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tFailure = ServerFailure(Exception('connection refused'));
  final tOtherFailure = GenericFailure(Exception('something else'));

  group('isLoading', () {
    test(
      '''
      GIVEN an AsyncLoading
      WHEN isLoading is read
      THEN it is true''',
      () {
        // given
        final AsyncValue<String> value = AsyncLoading();

        // when
        final isLoading = value is AsyncLoading<String>;

        // then
        expect(isLoading, isTrue);
      },
    );

    test(
      '''
      GIVEN an AsyncInitial, which means that nothing was requested yet
      WHEN isLoading is read
      THEN it is false''',
      () {
        // given
        final AsyncValue<String> value = AsyncInitial();

        // when
        final isLoading = value is AsyncLoading<String>;

        // then
        expect(isLoading, isFalse);
      },
    );

    test(
      '''
      GIVEN an AsyncData, which means that the value already arrived
      WHEN isLoading is read
      THEN it is false''',
      () {
        // given
        final AsyncValue<String> value = AsyncData('value');

        // when
        final isLoading = value is AsyncLoading<String>;

        // then
        expect(isLoading, isFalse);
      },
    );

    test(
      '''
      GIVEN an AsyncError, which means that the request already failed
      WHEN isLoading is read
      THEN it is false''',
      () {
        // given
        final AsyncValue<String> value = AsyncError(tFailure);

        // when
        final isLoading = value is AsyncLoading<String>;

        // then
        expect(isLoading, isFalse);
      },
    );
  });

  group('AsyncInitial', () {
    test(
      '''
      GIVEN two AsyncInitial values of the same type
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = AsyncInitial<String>();
        final second = AsyncInitial<String>();

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );
  });

  group('AsyncLoading', () {
    test(
      '''
      GIVEN two AsyncLoading values of the same type
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = AsyncLoading<String>();
        final second = AsyncLoading<String>();

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN an AsyncLoading and an AsyncInitial of the same type
      WHEN they are compared
      THEN they are not equal, so going from one to the other is a new state''',
      () {
        // given
        final AsyncValue<String> loading = AsyncLoading();
        final AsyncValue<String> initial = AsyncInitial();

        // when
        final areEqual = loading == initial;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  group('AsyncData', () {
    test(
      '''
      GIVEN a value that arrived
      WHEN an AsyncData is created with that value
      THEN it holds the value''',
      () {
        // given
        const tValue = 'value';

        // when
        final data = AsyncData(tValue);

        // then
        expect(data.value, tValue);
      },
    );

    test(
      '''
      GIVEN two AsyncData values that hold the same value
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = AsyncData('value');
        final second = AsyncData('value');

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two AsyncData values that hold different values
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AsyncData('value');
        final second = AsyncData('another value');

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  group('AsyncError', () {
    test(
      '''
      GIVEN a failure that stopped a request
      WHEN an AsyncError is created with that failure
      THEN it holds the failure''',
      () {
        // given
        final failure = tFailure;

        // when
        final error = AsyncError<String>(failure);

        // then
        expect(error.failure, same(tFailure));
      },
    );

    test(
      '''
      GIVEN two AsyncError values that hold the same failure
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = AsyncError<String>(tFailure);
        final second = AsyncError<String>(tFailure);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two AsyncError values that hold different failures
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AsyncError<String>(tFailure);
        final second = AsyncError<String>(tOtherFailure);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });
}
