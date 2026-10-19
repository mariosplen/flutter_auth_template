import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApi extends Mock implements AuthApi;

void main() {
  late AuthRemoteDataSource dataSource;
  late MockAuthApi mockAuthApi;

  setUp(() {
    mockAuthApi = MockAuthApi();
    dataSource = AuthRemoteDataSource(mockAuthApi);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  final tSessionModel = SessionModel(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );

  DioException buildDioException({int? statusCode, Object? data}) {
    final requestOptions = RequestOptions(path: '/auth/v1/token');
    return DioException(
      requestOptions: requestOptions,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: requestOptions,
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  DioException buildSupabaseAuthError(String errorCode) =>
      buildDioException(statusCode: 400, data: {'error_code': errorCode});

  group('signIn', () {
    void setUpMockAuthApiSignInError(DioException error) {
      when(() => mockAuthApi.signIn(any(), any())).thenThrow(error);
    }

    test(
      '''
      GIVEN an account with this email and password
      WHEN the user signs in with the email and the password
      THEN the session model from the API is returned
      AND the API was asked to sign in with the same email and password''',
      () async {
        // given
        when(() => mockAuthApi.signIn(any(), any()))
            .thenAnswer((_) async => tSessionModel);
        // when
        final result = await dataSource.signIn(
          email: tEmail,
          password: tPassword,
        );
        // then
        expect(result, same(tSessionModel));
        verify(() => mockAuthApi.signIn(tEmail, tPassword));
        verifyNoMoreInteractions(mockAuthApi);
      },
    );

    test(
      '''
      GIVEN the email or the password is wrong
      WHEN the user signs in
      THEN the "invalid_credentials" error from Supabase Auth is thrown as
           an invalid credentials auth failure
      AND its cause is the DioException from the API''',
      () async {
        // given
        final tError = buildSupabaseAuthError('invalid_credentials');
        setUpMockAuthApiSignInError(tError);
        // when
        final result = dataSource.signIn(email: tEmail, password: tPassword);
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.invalidCredentials, tError)),
        );
      },
    );

    test(
      '''
      GIVEN input that does not pass Supabase Auth's validation
      WHEN the user signs in
      THEN the "validation_failed" error from Supabase Auth is thrown as
           a validation failed auth failure''',
      () async {
        // given
        final tError = buildSupabaseAuthError('validation_failed');
        setUpMockAuthApiSignInError(tError);
        // when
        final result = dataSource.signIn(email: tEmail, password: tPassword);
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.validationFailed, tError)),
        );
      },
    );

    test(
      '''
      GIVEN the user has not confirmed the email address yet
      WHEN the user signs in
      THEN the "email_not_confirmed" error from Supabase Auth is thrown as
           an email not confirmed auth failure''',
      () async {
        // given
        final tError = buildSupabaseAuthError('email_not_confirmed');
        setUpMockAuthApiSignInError(tError);
        // when
        final result = dataSource.signIn(email: tEmail, password: tPassword);
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.emailNotConfirmed, tError)),
        );
      },
    );

    test(
      '''
      GIVEN the user has tried to sign in too many times
      WHEN the user signs in
      THEN the "over_request_rate_limit" error from Supabase Auth is thrown
           as an over request rate limit auth failure''',
      () async {
        // given
        final tError = buildSupabaseAuthError('over_request_rate_limit');
        setUpMockAuthApiSignInError(tError);
        // when
        final result = dataSource.signIn(email: tEmail, password: tPassword);
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.overRequestRateLimit, tError)),
        );
      },
    );

    test(
      '''
      GIVEN a sign in problem that the app has no error code for
      WHEN the user signs in
      THEN the error from Supabase Auth, with its unknown error code, is
           thrown as a server failure
      AND its cause is the DioException from the API''',
      () async {
        // given
        final tError = buildSupabaseAuthError('some_new_error_code');
        setUpMockAuthApiSignInError(tError);
        // when
        final result = dataSource.signIn(email: tEmail, password: tPassword);
        // then
        await expectLater(result, throwsA(ServerFailure(tError)));
      },
    );

    test(
      '''
      GIVEN the device is offline
      WHEN the user signs in
      THEN the connection error is thrown as a server failure''',
      () async {
        // given
        final tError = buildDioException();
        setUpMockAuthApiSignInError(tError);
        // when
        final result = dataSource.signIn(email: tEmail, password: tPassword);
        // then
        await expectLater(result, throwsA(ServerFailure(tError)));
      },
    );
  });

  group('signUp', () {
    const tSignUpResponseModel = SignUpNeedsConfirmation();

    void setUpMockAuthApiSignUpError(DioException error) {
      when(() => mockAuthApi.signUp(any(), any(), any())).thenThrow(error);
    }

    test(
      '''
      GIVEN no account exists for this email address yet
      WHEN the user signs up with the email, a password and a name
      THEN the sign up response model from the API is returned
      AND the API was asked to sign up with the same email and password
      AND the name was sent in the user metadata''',
      () async {
        // given
        when(() => mockAuthApi.signUp(any(), any(), any()))
            .thenAnswer((_) async => tSignUpResponseModel);
        // when
        final result = await dataSource.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );
        // then
        expect(result, tSignUpResponseModel);
        verify(() => mockAuthApi.signUp(tEmail, tPassword, {'name': tName}));
        verifyNoMoreInteractions(mockAuthApi);
      },
    );

    test(
      '''
      GIVEN there is already an account with this email address
      WHEN the user signs up
      THEN the "user_already_exists" error from Supabase Auth is thrown as
           a user already exists auth failure''',
      () async {
        // given
        final tError = buildSupabaseAuthError('user_already_exists');
        setUpMockAuthApiSignUpError(tError);
        // when
        final result = dataSource.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.userAlreadyExists, tError)),
        );
      },
    );

    test(
      '''
      GIVEN an email address that Supabase Auth does not accept
      WHEN the user signs up with it
      THEN the "email_address_invalid" error from Supabase Auth is thrown as
           an email address invalid auth failure''',
      () async {
        // given
        final tError = buildSupabaseAuthError('email_address_invalid');
        setUpMockAuthApiSignUpError(tError);
        // when
        final result = dataSource.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.emailAddressInvalid, tError)),
        );
      },
    );

    test(
      '''
      GIVEN a password that Supabase Auth considers too weak
      WHEN the user signs up
      THEN the "weak_password" error from Supabase Auth is thrown as
           a weak password auth failure''',
      () async {
        // given
        final tError = buildSupabaseAuthError('weak_password');
        setUpMockAuthApiSignUpError(tError);
        // when
        final result = dataSource.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.weakPassword, tError)),
        );
      },
    );

    test(
      '''
      GIVEN too many emails were sent to this email address recently
      WHEN the user signs up
      THEN the "over_email_send_rate_limit" error from Supabase Auth is
           thrown as an over email send rate limit auth failure''',
      () async {
        // given
        final tError = buildSupabaseAuthError('over_email_send_rate_limit');
        setUpMockAuthApiSignUpError(tError);
        // when
        final result = dataSource.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );
        // then
        await expectLater(
          result,
          throwsA(AuthFailure(AuthFailureType.overEmailSendRateLimit, tError)),
        );
      },
    );
  });

  group('signOut', () {
    test(
      '''
      GIVEN a signed in user
      WHEN the user signs out
      THEN the API was asked to sign out''',
      () async {
        // given
        when(() => mockAuthApi.signOut()).thenAnswer((_) async {});
        // when
        await dataSource.signOut();
        // then
        verify(() => mockAuthApi.signOut()).called(1);
        verifyNoMoreInteractions(mockAuthApi);
      },
    );

    test(
      '''
      GIVEN the user has made too many requests
      WHEN the user signs out
      THEN the "over_request_rate_limit" error from Supabase Auth is thrown
           as a server failure, not as an auth failure, because sign out
           errors are never shown to the user''',
      () async {
        // given
        final tError = buildSupabaseAuthError('over_request_rate_limit');
        when(() => mockAuthApi.signOut()).thenThrow(tError);
        // when
        final result = dataSource.signOut();
        // then
        await expectLater(result, throwsA(ServerFailure(tError)));
      },
    );
  });
}
