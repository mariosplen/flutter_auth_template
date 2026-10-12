import 'package:flutter_auth_template/core/di/register_module.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class TestRegisterModule extends RegisterModule {}

void main() {
  late RegisterModule registerModule;

  setUp(() {
    registerModule = TestRegisterModule();
  });

  group('dio', () {
    test(
      '''
      GIVEN the tests run without the Supabase dart-defines
      WHEN the module is asked for its Dio
      THEN it throws a StateError
      AND that proves the Dio comes from createDio and its environment check''',
      () {
        // given
        const hasSupabaseUrl = bool.hasEnvironment('SUPABASE_URL');
        expect(
          hasSupabaseUrl,
          isFalse,
          reason: 'Run the tests without the Supabase dart-defines.',
        );

        // when
        Object call() => registerModule.dio;

        // then
        expect(call, throwsStateError);
      },
    );
  });

  group('secureStorage', () {
    test(
      '''
      GIVEN a register module
      WHEN the module is asked for its secure storage
      THEN it returns a FlutterSecureStorage''',
      () {
        // when
        final secureStorage = registerModule.secureStorage;

        // then
        expect(secureStorage, isA<FlutterSecureStorage>());
      },
    );
  });
}
