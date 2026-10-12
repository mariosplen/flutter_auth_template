import 'package:flutter/services.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/session_storage.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/user_model.dart';
import 'package:flutter_auth_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSessionStorage extends Mock implements SessionStorage {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSessionStorage mockSessionStorage;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSessionStorage = MockSessionStorage();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      sessionStorage: mockSessionStorage,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  const tUser = User(id: tUserId, email: tEmail);
  final tSessionModel = SessionModel(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    user: UserModel(id: tUserId, email: tEmail),
  );
  final tAuthFailure = AuthFailure(
    .invalidCredentials,
    Exception('invalid credentials'),
  );
  final tUnexpectedError = StateError('the response could not be parsed');
  final tStorageError = PlatformException(code: 'keystore_unavailable');

  void setUpMockSessionStorageSaveSuccess() {
    when(() => mockSessionStorage.save(tSessionModel)).thenAnswer((_) async {});
  }

  group('currentUser', () {
    test(
      '''
      GIVEN the session storage holds a session
      WHEN the current user is read
      THEN it is the user of that session, mapped to a User entity''',
      () {
        // given
        when(() => mockSessionStorage.session).thenReturn(tSessionModel);

        // when
        final currentUser = repository.currentUser;

        // then
        expect(currentUser, tUser);
      },
    );

    test(
      '''
      GIVEN the session storage holds no session
      WHEN the current user is read
      THEN there is no current user''',
      () {
        // given
        when(() => mockSessionStorage.session).thenReturn(null);

        // when
        final currentUser = repository.currentUser;

        // then
        expect(currentUser, isNull);
      },
    );
  });

  group('signIn', () {
    void setUpMockRemoteDataSourceSignInSuccess() {
      when(
        () => mockRemoteDataSource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tSessionModel);
    }

    void setUpMockRemoteDataSourceSignInThrows(Object error) {
      when(
        () => mockRemoteDataSource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(error);
    }

    test(
      '''
      GIVEN the remote data source signs the user in and returns a session
      WHEN signIn is called with an email and a password
      THEN the remote data source is asked with that email and that password
      AND the session is saved to the session storage
      AND an Ok with the user of the session is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceSignInSuccess();
        setUpMockSessionStorageSaveSuccess();

        // when
        final result = await repository.signIn(
          email: tEmail,
          password: tPassword,
        );

        // then
        verify(
          () => mockRemoteDataSource.signIn(email: tEmail, password: tPassword),
        ).called(1);
        verify(() => mockSessionStorage.save(tSessionModel)).called(1);
        expect(
          result,
          isA<Ok<User>>().having((ok) => ok.value, 'value', tUser),
        );
      },
    );

    test(
      '''
      GIVEN the remote data source throws a Failure, like wrong credentials
      WHEN signIn is called
      THEN an Error with that very Failure is returned
      AND nothing is saved to the session storage''',
      () async {
        // given
        setUpMockRemoteDataSourceSignInThrows(tAuthFailure);

        // when
        final result = await repository.signIn(
          email: tEmail,
          password: tPassword,
        );

        // then
        expect(
          result,
          isA<Error<User>>().having(
            (error) => error.failure,
            'failure',
            same(tAuthFailure),
          ),
        );
        verifyZeroInteractions(mockSessionStorage);
      },
    );

    test(
      '''
      GIVEN the remote data source throws something that is not a Failure,
            like a response that could not be parsed
      WHEN signIn is called
      THEN an Error with a GenericFailure is returned
      AND the GenericFailure carries what was thrown as its cause
      AND nothing is saved to the session storage''',
      () async {
        // given
        setUpMockRemoteDataSourceSignInThrows(tUnexpectedError);

        // when
        final result = await repository.signIn(
          email: tEmail,
          password: tPassword,
        );

        // then
        expect(
          result,
          isA<Error<User>>().having(
            (error) => error.failure,
            'failure',
            GenericFailure(tUnexpectedError),
          ),
        );
        verifyZeroInteractions(mockSessionStorage);
      },
    );

    test(
      '''
      GIVEN the remote data source signs the user in
      AND the session storage fails to save the session
      WHEN signIn is called
      THEN an Error with a GenericFailure is returned
      AND the GenericFailure carries the error of the storage as its cause''',
      () async {
        // given
        setUpMockRemoteDataSourceSignInSuccess();
        when(() => mockSessionStorage.save(tSessionModel))
            .thenThrow(tStorageError);

        // when
        final result = await repository.signIn(
          email: tEmail,
          password: tPassword,
        );

        // then
        expect(
          result,
          isA<Error<User>>().having(
            (error) => error.failure,
            'failure',
            GenericFailure(tStorageError),
          ),
        );
      },
    );
  });

  group('signUp', () {
    void setUpMockRemoteDataSourceSignUpSuccess(SignUpResponseModel response) {
      when(
        () => mockRemoteDataSource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => response);
    }

    void setUpMockRemoteDataSourceSignUpThrows(Object error) {
      when(
        () => mockRemoteDataSource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenThrow(error);
    }

    test(
      '''
      GIVEN the remote data source creates the account and returns a session
      WHEN signUp is called with an email, a password and a name
      THEN the remote data source is asked with that email, password and name
      AND the session is saved to the session storage
      AND an Ok with a SignedUp that holds the user of the session is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceSignUpSuccess(
          SignedUpWithSession(tSessionModel),
        );
        setUpMockSessionStorageSaveSuccess();

        // when
        final result = await repository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );

        // then
        verify(
          () => mockRemoteDataSource.signUp(
            email: tEmail,
            password: tPassword,
            name: tName,
          ),
        ).called(1);
        verify(() => mockSessionStorage.save(tSessionModel)).called(1);
        expect(
          result,
          isA<Ok<SignUpResult>>().having(
            (ok) => ok.value,
            'value',
            isA<SignedUp>().having((signedUp) => signedUp.user, 'user', tUser),
          ),
        );
      },
    );

    test(
      '''
      GIVEN the remote data source creates the account
      AND the email has to be confirmed before there is a session
      WHEN signUp is called
      THEN an Ok with a ConfirmationRequired is returned
      AND nothing is saved to the session storage''',
      () async {
        // given
        setUpMockRemoteDataSourceSignUpSuccess(const SignUpNeedsConfirmation());

        // when
        final result = await repository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );

        // then
        expect(
          result,
          isA<Ok<SignUpResult>>().having(
            (ok) => ok.value,
            'value',
            isA<ConfirmationRequired>(),
          ),
        );
        verifyZeroInteractions(mockSessionStorage);
      },
    );

    test(
      '''
      GIVEN the remote data source throws a Failure, like an existing account
      WHEN signUp is called
      THEN an Error with that very Failure is returned
      AND nothing is saved to the session storage''',
      () async {
        // given
        setUpMockRemoteDataSourceSignUpThrows(tAuthFailure);

        // when
        final result = await repository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );

        // then
        expect(
          result,
          isA<Error<SignUpResult>>().having(
            (error) => error.failure,
            'failure',
            same(tAuthFailure),
          ),
        );
        verifyZeroInteractions(mockSessionStorage);
      },
    );

    test(
      '''
      GIVEN the remote data source throws something that is not a Failure,
            like a response that could not be parsed
      WHEN signUp is called
      THEN an Error with a GenericFailure is returned
      AND the GenericFailure carries what was thrown as its cause
      AND nothing is saved to the session storage''',
      () async {
        // given
        setUpMockRemoteDataSourceSignUpThrows(tUnexpectedError);

        // when
        final result = await repository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );

        // then
        expect(
          result,
          isA<Error<SignUpResult>>().having(
            (error) => error.failure,
            'failure',
            GenericFailure(tUnexpectedError),
          ),
        );
        verifyZeroInteractions(mockSessionStorage);
      },
    );
  });

  group('signOut', () {
    test(
      '''
      GIVEN the remote data source signs the user out
      WHEN signOut is called
      THEN the remote data source is asked to sign out first
      AND the session storage is cleared after that''',
      () async {
        // given
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async {});
        when(() => mockSessionStorage.clear()).thenAnswer((_) async {});

        // when
        await repository.signOut();

        // then
        verifyInOrder([
          () => mockRemoteDataSource.signOut(),
          () => mockSessionStorage.clear(),
        ]);
      },
    );

    test(
      '''
      GIVEN the remote data source fails to sign the user out,
            as when the device is offline
      WHEN signOut is called
      THEN it completes without throwing
      AND the session storage is cleared all the same,
          so the user is signed out on this device''',
      () async {
        // given
        when(() => mockRemoteDataSource.signOut())
            .thenThrow(ServerFailure(Exception('offline')));
        when(() => mockSessionStorage.clear()).thenAnswer((_) async {});

        // when
        await repository.signOut();

        // then
        verify(() => mockSessionStorage.clear()).called(1);
      },
    );

    test(
      '''
      GIVEN the remote data source signs the user out
      AND the session storage fails while it is being cleared
      WHEN signOut is called
      THEN it completes without throwing''',
      () async {
        // given
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async {});
        when(() => mockSessionStorage.clear()).thenThrow(tStorageError);

        // when
        final signOut = repository.signOut();

        // then
        await expectLater(signOut, completes);
        verify(() => mockSessionStorage.clear()).called(1);
      },
    );
  });
}
