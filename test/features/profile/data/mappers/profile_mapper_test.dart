import 'package:flutter_auth_template/features/profile/data/mappers/profile_mapper.dart';
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tName = 'Test User';
  final tCreatedAt = DateTime.utc(2026, 1, 1, 10);

  group('toEntity', () {
    test(
      '''
      GIVEN a ProfileResponseModel that came from the data layer
      WHEN it is mapped to an entity
      THEN the result is a Profile of the domain layer
      AND the Profile has the name and the creation date of the model''',
      () {
        // given
        final model = ProfileResponseModel(name: tName, createdAt: tCreatedAt);

        // when
        final entity = model.toEntity();

        // then
        expect(entity, Profile(name: tName, createdAt: tCreatedAt));
      },
    );
  });
}
