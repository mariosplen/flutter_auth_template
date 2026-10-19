import 'package:flutter/services.dart';
import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_auth_template/core/app/domain/repositories/session_repository.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_auth_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource;

class MockSessionRepository extends Mock implements SessionRepository;

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSessionRepository mockSessionRepository;

  setUpAll(() {
    registerFallbackValue(const Session(accessToken: '', refreshToken: ''));
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSessionRepository = MockSessionRepository();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      sessionRepository: mockSessionRepository,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  const tSession = Session(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );
  final tSessionModel = SessionModel(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );
  const tFailure = AuthFailure(AuthFailureType.invalidCredentials, 'cause');

  void setUpMockSessionRepositorySaveSuccess() {
    when(() => mockSessionRepository.save(any())).thenAnswer((_) async {});
  }

  group('signIn', () {
    void setUpMockRemoteDataSourceSignIn(Future<SessionModel> Function() call) {
      when(
        () => mockRemoteDataSource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => call());
    }

    test(
      '''
      GIVEN an account with this email and password
      WHEN the user signs in with the email and the password
      THEN the remote data source was asked to sign in with the same email
           and password
      AND the session from the response is saved, so the user is signed in
      AND an Ok result is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceSignIn(() async => tSessionModel);
        setUpMockSessionRepositorySaveSuccess();
        // when
        final result = await repository.signIn(
          email: tEmail,
          password: tPassword,
        );
        // then
        verify(
          () => mockRemoteDataSource.signIn(email: tEmail, password: tPassword),
        );
        verify(() => mockSessionRepository.save(tSession)).called(1);
        expect(result, isA<Ok<void>>());
      },
    );

    test(
      '''
      GIVEN the password is wrong
      WHEN the user signs in
      THEN no session is saved, so the user stays signed out
      AND an Error result with the auth failure from the remote data source
          is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceSignIn(() async => throw tFailure);
        // when
        final result = await repository.signIn(
          email: tEmail,
          password: tPassword,
        );
        // then
        verifyZeroInteractions(mockSessionRepository);
        expect(
          result,
          isA<Error<void>>().having((e) => e.failure, 'failure', tFailure),
        );
      },
    );

    test(
      '''
      GIVEN an account with this email and password
      AND secure storage is unavailable
      WHEN the user signs in
      THEN an Error result with a generic failure is returned''',
      () async {
        // given
        final tError = PlatformException(code: 'unavailable');
        setUpMockRemoteDataSourceSignIn(() async => tSessionModel);
        when(() => mockSessionRepository.save(any())).thenThrow(tError);
        // when
        final result = await repository.signIn(
          email: tEmail,
          password: tPassword,
        );
        // then
        expect(
          result,
          isA<Error<void>>().having(
            (e) => e.failure,
            'failure',
            GenericFailure(tError),
          ),
        );
      },
    );
  });

  group('signUp', () {
    void setUpMockRemoteDataSourceSignUp(
      Future<SignUpResponseModel> Function() call,
    ) {
      when(
        () => mockRemoteDataSource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) => call());
    }

    Future<Result<SignUpResult>> signUp() =>
        repository.signUp(email: tEmail, password: tPassword, name: tName);

    test(
      '''
      GIVEN email confirmation is turned off in Supabase
      WHEN the user signs up with an email, a password and a name
      THEN the remote data source was asked to sign up with the same email,
           password and name
      AND the session from the response is saved, so the user is signed in
      AND an Ok result with signed up is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceSignUp(
          () async => SignedUpWithSession(tSessionModel),
        );
        setUpMockSessionRepositorySaveSuccess();
        // when
        final result = await signUp();
        // then
        verify(
          () => mockRemoteDataSource.signUp(
            email: tEmail,
            password: tPassword,
            name: tName,
          ),
        );
        verify(() => mockSessionRepository.save(tSession)).called(1);
        expect(
          result,
          isA<Ok<SignUpResult>>().having(
            (ok) => ok.value,
            'value',
            isA<SignedUp>(),
          ),
        );
      },
    );

    test(
      '''
      GIVEN email confirmation is turned on in Supabase
      WHEN the user signs up
      THEN no session is saved, because the response has none
      AND an Ok result with confirmation required is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceSignUp(
          () async => const SignUpNeedsConfirmation(),
        );
        // when
        final result = await signUp();
        // then
        verifyZeroInteractions(mockSessionRepository);
        expect(
          result,
          isA<Ok<SignUpResult>>().having(
            (ok) => ok.value,
            'value',
            isA<ConfirmationRequired>(),
          ),
        );
      },
    );

    test(
      '''
      GIVEN there is already an account with this email address
      WHEN the user signs up
      THEN an Error result with the auth failure from the remote data source
           is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceSignUp(() async => throw tFailure);
        // when
        final result = await signUp();
        // then
        verifyZeroInteractions(mockSessionRepository);
        expect(
          result,
          isA<Error<SignUpResult>>().having(
            (e) => e.failure,
            'failure',
            tFailure,
          ),
        );
      },
    );

    test(
      '''
      GIVEN Supabase Auth's sign up response has a shape the app does not
            expect
      WHEN the user signs up
      THEN an Error result with a generic failure is returned''',
      () async {
        // given
        const tError = FormatException('unexpected response');
        setUpMockRemoteDataSourceSignUp(() async => throw tError);
        // when
        final result = await signUp();
        // then
        expect(
          result,
          isA<Error<SignUpResult>>().having(
            (e) => e.failure,
            'failure',
            const GenericFailure(tError),
          ),
        );
      },
    );
  });

  group('signOut', () {
    test(
      '''
      GIVEN a signed in user
      WHEN the user signs out
      THEN the remote data source was asked to sign out
      AND the session is cleared, so the user is signed out''',
      () async {
        // given
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async {});
        when(() => mockSessionRepository.clear()).thenAnswer((_) async {});
        // when
        await repository.signOut();
        // then
        verify(() => mockRemoteDataSource.signOut()).called(1);
        verify(() => mockSessionRepository.clear()).called(1);
      },
    );

    test(
      '''
      GIVEN a signed in user
      AND the device is offline
      WHEN the user signs out
      THEN the session is still cleared, so the user is signed out locally
      AND signing out completes without throwing''',
      () async {
        // given
        when(() => mockRemoteDataSource.signOut())
            .thenThrow(const ServerFailure('offline'));
        when(() => mockSessionRepository.clear()).thenAnswer((_) async {});
        // when
        await repository.signOut();
        // then
        verify(() => mockSessionRepository.clear()).called(1);
      },
    );

    test(
      '''
      GIVEN a signed in user
      AND secure storage is unavailable
      WHEN the user signs out
      THEN signing out completes without throwing, because the session in
           memory is already cleared''',
      () async {
        // given
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async {});
        when(() => mockSessionRepository.clear())
            .thenThrow(PlatformException(code: 'unavailable'));
        // when
        final result = repository.signOut();
        // then
        await expectLater(result, completes);
      },
    );
  });
}
