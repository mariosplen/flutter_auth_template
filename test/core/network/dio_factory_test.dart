import 'package:flutter_auth_template/core/network/dio_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('createDio', () {
    test(
      '''
      GIVEN the app was started without --dart-define-from-file, so there is
            no Supabase URL and no publishable key
      WHEN the Dio client is created
      THEN a StateError is thrown that says how to run the app''',
      () async {
        // when
        final result = Future.sync(createDio);
        // then
        await expectLater(
          result,
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('--dart-define-from-file=env/dev.json'),
            ),
          ),
        );
      },
    );

    test(
      '''
      GIVEN a Supabase URL
      AND no publishable key
      WHEN the Dio client is created
      THEN a StateError is thrown''',
      () async {
        // given
        const tUrl = 'https://test-project.supabase.co';
        // when
        final result = Future.sync(() => createDio(url: tUrl));
        // then
        await expectLater(result, throwsA(isA<StateError>()));
      },
    );

    test(
      '''
      GIVEN a publishable key
      AND no Supabase URL
      WHEN the Dio client is created
      THEN a StateError is thrown''',
      () async {
        // given
        const tPublishableKey = 'sb_publishable_test';
        // when
        final result = Future.sync(
          () => createDio(publishableKey: tPublishableKey),
        );
        // then
        await expectLater(result, throwsA(isA<StateError>()));
      },
    );

    test(
      '''
      GIVEN a Supabase URL and a publishable key
      WHEN the Dio client is created
      THEN its requests go to the Supabase URL
      AND every request sends the publishable key in the "apikey" header
      AND connecting and receiving each time out after 15 seconds''',
      () {
        // given
        const tUrl = 'https://test-project.supabase.co';
        const tPublishableKey = 'sb_publishable_test';
        // when
        final result = createDio(url: tUrl, publishableKey: tPublishableKey);
        // then
        expect(result.options.baseUrl, tUrl);
        expect(result.options.headers['apikey'], tPublishableKey);
        expect(result.options.connectTimeout, const Duration(seconds: 15));
        expect(result.options.receiveTimeout, const Duration(seconds: 15));
      },
    );
  });
}
