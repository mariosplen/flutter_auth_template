import 'package:flutter_auth_template/features/profile/data/mappers/profile_mapper.dart';
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toEntity', () {
    test(
      '''
      GIVEN a profile response model from the server, which has no email
      AND the email of the signed in user
      WHEN it is mapped to an entity with that email
      THEN the profile entity has the same id, name and creation date
      AND it has the email of the user''',
      () {
        // given
        final tCreatedAt = DateTime.utc(2026, 1, 1, 10);
        final tProfileResponseModel = ProfileResponseModel(
          id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
          name: 'Test User',
          createdAt: tCreatedAt,
        );
        // when
        final result = tProfileResponseModel.toEntity(
          email: 'test@example.com',
        );
        // then
        expect(
          result,
          Profile(
            id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
            name: 'Test User',
            email: 'test@example.com',
            createdAt: tCreatedAt,
          ),
        );
      },
    );
  });
}
