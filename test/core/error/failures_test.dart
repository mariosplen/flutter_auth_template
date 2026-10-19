import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServerFailure', () {
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
  });
}
