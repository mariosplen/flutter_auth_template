import 'package:flutter_auth_template/core/app/data/mappers/session_mapper.dart';
import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tAccessToken = 'test-access-token';
  const tRefreshToken = 'test-refresh-token';

  group('toEntity', () {
    test(
      '''
      GIVEN a session model with an access token and a refresh token
      WHEN it is mapped to an entity
      THEN the session entity has the same access token and refresh token''',
      () {
        // given
        final tSessionModel = SessionModel(
          accessToken: tAccessToken,
          refreshToken: tRefreshToken,
        );
        // when
        final result = tSessionModel.toEntity();
        // then
        expect(
          result,
          const Session(accessToken: tAccessToken, refreshToken: tRefreshToken),
        );
      },
    );
  });

  group('toModel', () {
    test(
      '''
      GIVEN a session entity with an access token and a refresh token
      WHEN it is mapped to a model, so it can be stored
      THEN the session model has the same access token and refresh token''',
      () {
        // given
        const tSession = Session(
          accessToken: tAccessToken,
          refreshToken: tRefreshToken,
        );
        // when
        final result = tSession.toModel();
        // then
        expect(result.accessToken, tAccessToken);
        expect(result.refreshToken, tRefreshToken);
      },
    );
  });
}
