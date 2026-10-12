import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/di/dio_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tUrl = 'https://test-project.supabase.co';
  const tPublishableKey = 'sb_publishable_test';

  group('createDio', () {
    test(
      '''
      GIVEN a Supabase url and a publishable key
      WHEN createDio is called with them
      THEN it returns a Dio that uses the url as its base url
      AND it sends the publishable key in the apikey header of every request
      AND it gives up connecting or receiving after 15 seconds''',
      () {
        // when
        final dio = createDio(url: tUrl, publishableKey: tPublishableKey);

        // then
        expect(dio, isA<Dio>());
        expect(dio.options.baseUrl, tUrl);
        expect(dio.options.headers['apikey'], tPublishableKey);
        expect(dio.options.connectTimeout, const Duration(seconds: 15));
        expect(dio.options.receiveTimeout, const Duration(seconds: 15));
      },
    );

    test(
      '''
      GIVEN the Supabase url is missing
      WHEN createDio is called
      THEN it throws a StateError
      AND the error explains how to run the app with the env file''',
      () {
        // given
        const tMissingUrl = '';

        // when
        Dio call() =>
            createDio(url: tMissingUrl, publishableKey: tPublishableKey);

        // then
        expect(
          call,
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
      GIVEN the Supabase publishable key is missing
      WHEN createDio is called
      THEN it throws a StateError
      AND the error explains how to run the app with the env file''',
      () {
        // given
        const tMissingPublishableKey = '';

        // when
        Dio call() =>
            createDio(url: tUrl, publishableKey: tMissingPublishableKey);

        // then
        expect(
          call,
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
  });
}
