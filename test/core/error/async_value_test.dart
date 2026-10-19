import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

// type parameters keep these from being shared const instances
AsyncValue<T> buildInitial<T>() => AsyncInitial<T>();

AsyncValue<T> buildLoading<T>() => AsyncLoading<T>();

void main() {
  group('AsyncInitial', () {
    test(
      '''
      GIVEN an async value that has not started
      AND an async value that is loading
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final tInitial = buildInitial<int>();
        final tLoading = buildLoading<int>();
        // when
        final isEqual = tInitial == tLoading;
        // then
        expect(isEqual, isFalse);
      },
    );
  });

  group('AsyncLoading', () {
    test(
      '''
      GIVEN two async values that are loading, created separately
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final tFirst = buildLoading<int>();
        final tSecond = buildLoading<int>();
        // when
        final isEqual = tFirst == tSecond;
        // then
        expect(isEqual, isTrue);
      },
    );
  });

  group('AsyncData', () {
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
