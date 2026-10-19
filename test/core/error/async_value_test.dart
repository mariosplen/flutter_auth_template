import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsyncInitial', () {
    test(
      '''
      GIVEN two async values for operations that have not started
      WHEN they are compared
      THEN they are equal
      AND they have the same hash code''',
      () {
        // given
        const tFirst = AsyncInitial<int>();
        const tSecond = AsyncInitial<int>();
        // when
        final isEqual = tFirst == tSecond;
        final hasSameHashCode = tFirst.hashCode == tSecond.hashCode;
        // then
        expect(isEqual, isTrue);
        expect(hasSameHashCode, isTrue);
      },
    );
  });

  group('AsyncLoading', () {
    test(
      '''
      GIVEN two async values for operations that are loading
      WHEN they are compared
      THEN they are equal
      AND they have the same hash code''',
      () {
        // given
        const tFirst = AsyncLoading<int>();
        const tSecond = AsyncLoading<int>();
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
      GIVEN an async value that is loading
      AND an async value that has not started
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        const AsyncValue<int> tLoading = AsyncLoading();
        const AsyncValue<int> tInitial = AsyncInitial();
        // when
        final isEqual = tLoading == tInitial;
        // then
        expect(isEqual, isFalse);
      },
    );
  });

  group('AsyncData', () {
    test(
      '''
      GIVEN an async value that loaded the value 1
      WHEN its value is read
      THEN the value is 1''',
      () {
        // given
        const tAsyncData = AsyncData(1);
        // when
        final result = tAsyncData.value;
        // then
        expect(result, 1);
      },
    );

    test(
      '''
      GIVEN two async values that loaded the same value
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        const tFirst = AsyncData(1);
        const tSecond = AsyncData(1);
        // when
        final isEqual = tFirst == tSecond;
        // then
        expect(isEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two async values that loaded different values
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        const tFirst = AsyncData(1);
        const tSecond = AsyncData(2);
        // when
        final isEqual = tFirst == tSecond;
        // then
        expect(isEqual, isFalse);
      },
    );
  });

  group('AsyncError', () {
    test(
      '''
      GIVEN an async value that failed with a server failure
      WHEN its failure is read
      THEN it is the same server failure''',
      () {
        // given
        const tFailure = ServerFailure('cause');
        const tAsyncError = AsyncError<int>(tFailure);
        // when
        final result = tAsyncError.failure;
        // then
        expect(result, tFailure);
      },
    );

    test(
      '''
      GIVEN two async values that failed with failures with different causes
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        const tFirst = AsyncError<int>(ServerFailure('first cause'));
        const tSecond = AsyncError<int>(ServerFailure('second cause'));
        // when
        final isEqual = tFirst == tSecond;
        // then
        expect(isEqual, isFalse);
      },
    );
  });
}
