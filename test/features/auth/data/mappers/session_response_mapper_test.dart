import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_auth_template/features/auth/data/mappers/session_response_mapper.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toEntity', () {
    test(
      '''
      GIVEN a session response model from Supabase Auth
      WHEN it is mapped to an entity
      THEN the session entity has the same access token and refresh token''',
      () {
        // given
        final tSessionResponseModel = SessionResponseModel(
          accessToken: 'test-access-token',
          refreshToken: 'test-refresh-token',
        );
        // when
        final result = tSessionResponseModel.toEntity();
        // then
        expect(
          result,
          const Session(
            accessToken: 'test-access-token',
            refreshToken: 'test-refresh-token',
          ),
        );
      },
    );
  });
}
