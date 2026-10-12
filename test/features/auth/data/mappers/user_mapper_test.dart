import 'package:flutter_auth_template/features/auth/data/mappers/user_mapper.dart';
import 'package:flutter_auth_template/features/auth/data/models/user_model.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  const tEmail = 'test@example.com';

  group('toEntity', () {
    test(
      '''
      GIVEN a UserModel that came from the data layer
      WHEN it is mapped to an entity
      THEN the result is a User of the domain layer
      AND the User has the id and the email of the model''',
      () {
        // given
        final model = UserModel(id: tId, email: tEmail);

        // when
        final entity = model.toEntity();

        // then
        expect(entity, const User(id: tId, email: tEmail));
      },
    );
  });
}
