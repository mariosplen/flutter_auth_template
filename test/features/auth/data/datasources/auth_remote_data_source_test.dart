import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/user_model.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApi extends Mock implements AuthApi {}

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
    user: UserModel(id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f', email: tEmail),
  );

  const tAuthFailureTypesByErrorCode = {
    'email_address_invalid': AuthFailureType.emailAddressInvalid,
    'validation_failed': AuthFailureType.validationFailed,
    'invalid_credentials': AuthFailureType.invalidCredentials,
    'email_not_confirmed': AuthFailureType.emailNotConfirmed,
    'user_already_exists': AuthFailureType.userAlreadyExists,
    'weak_password': AuthFailureType.weakPassword,
    'over_request_rate_limit': AuthFailureType.overRequestRateLimit,
    'over_email_send_rate_limit': AuthFailureType.overEmailSendRateLimit,
  };

  DioException buildDioExceptionWithResponseData(Object? data) {
    final requestOptions = RequestOptions(path: '/auth/v1');
    return DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 400,
        data: data,
      ),
    );
  }

  DioException buildDioExceptionWithErrorCode(String errorCode) =>
      buildDioExceptionWithResponseData({
        'code': 400,
        'error_code': errorCode,
        'msg': 'Something is wrong with the request',
      });

  DioException buildDioExceptionWithoutResponse() => DioException(
    requestOptions: RequestOptions(path: '/auth/v1'),
    type: .connectionError,
  );

  group('signIn', () {
    void setUpMockAuthApiSignInThrows(Object error) {
      when(() => mockAuthApi.signIn(any(), any())).thenThrow(error);
    }

    test(
      '''
      GIVEN the API accepts the credentials and answers with a session
      WHEN signIn is called with an email and a password
      THEN the API is asked to sign in with that email and that password
      AND the session of the API is returned''',
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
        verify(() => mockAuthApi.signIn(tEmail, tPassword)).called(1);
        verifyNoMoreInteractions(mockAuthApi);
      },
    );

    for (final MapEntry(key: tErrorCode, value: tAuthFailureType)
        in tAuthFailureTypesByErrorCode.entries) {
      test(
        '''
        GIVEN the API rejects the request with the "$tErrorCode" error code
        WHEN signIn is called
        THEN an AuthFailure of the type ${tAuthFailureType.name} is thrown
        AND the failure carries the DioException of the API as its cause''',
        () async {
          // given
          final tDioException = buildDioExceptionWithErrorCode(tErrorCode);
          setUpMockAuthApiSignInThrows(tDioException);

          // when
          final call = dataSource.signIn;

          // then
          await expectLater(
            () => call(email: tEmail, password: tPassword),
            throwsA(AuthFailure(tAuthFailureType, tDioException)),
          );
        },
      );
    }

    test(
      '''
      GIVEN the API rejects the request with an error code
            that the app does not know about
      WHEN signIn is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        final tDioException = buildDioExceptionWithErrorCode('otp_expired');
        setUpMockAuthApiSignInThrows(tDioException);

        // when
        final call = dataSource.signIn;

        // then
        await expectLater(
          () => call(email: tEmail, password: tPassword),
          throwsA(ServerFailure(tDioException)),
        );
      },
    );

    test(
      '''
      GIVEN the API fails with a response that has no error code at all,
            like the HTML page of a gateway error
      WHEN signIn is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        final tDioException = buildDioExceptionWithResponseData(
          '<html>502 Bad Gateway</html>',
        );
        setUpMockAuthApiSignInThrows(tDioException);

        // when
        final call = dataSource.signIn;

        // then
        await expectLater(
          () => call(email: tEmail, password: tPassword),
          throwsA(ServerFailure(tDioException)),
        );
      },
    );

    test(
      '''
      GIVEN the request never gets a response, as when the device is offline
      WHEN signIn is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        final tDioException = buildDioExceptionWithoutResponse();
        setUpMockAuthApiSignInThrows(tDioException);

        // when
        final call = dataSource.signIn;

        // then
        await expectLater(
          () => call(email: tEmail, password: tPassword),
          throwsA(ServerFailure(tDioException)),
        );
      },
    );
  });

  group('signUp', () {
    void setUpMockAuthApiSignUpThrows(Object error) {
      when(() => mockAuthApi.signUp(any(), any(), any())).thenThrow(error);
    }

    test(
      '''
      GIVEN the API creates the account and answers with a session
      WHEN signUp is called with an email, a password and a name
      THEN the API is asked to sign up with that email and that password
      AND the name is sent as the "name" of the user metadata
      AND the response of the API is returned''',
      () async {
        // given
        final tSignUpResponseModel = SignedUpWithSession(tSessionModel);
        when(() => mockAuthApi.signUp(any(), any(), any()))
            .thenAnswer((_) async => tSignUpResponseModel);

        // when
        final result = await dataSource.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );

        // then
        expect(result, same(tSignUpResponseModel));
        verify(() => mockAuthApi.signUp(tEmail, tPassword, {'name': tName}))
            .called(1);
        verifyNoMoreInteractions(mockAuthApi);
      },
    );

    test(
      '''
      GIVEN the API creates the account but the email has to be confirmed first
      WHEN signUp is called
      THEN the "needs confirmation" response of the API is returned''',
      () async {
        // given
        const tSignUpResponseModel = SignUpNeedsConfirmation();
        when(() => mockAuthApi.signUp(any(), any(), any()))
            .thenAnswer((_) async => tSignUpResponseModel);

        // when
        final result = await dataSource.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        );

        // then
        expect(result, same(tSignUpResponseModel));
      },
    );

    for (final MapEntry(key: tErrorCode, value: tAuthFailureType)
        in tAuthFailureTypesByErrorCode.entries) {
      test(
        '''
        GIVEN the API rejects the request with the "$tErrorCode" error code
        WHEN signUp is called
        THEN an AuthFailure of the type ${tAuthFailureType.name} is thrown
        AND the failure carries the DioException of the API as its cause''',
        () async {
          // given
          final tDioException = buildDioExceptionWithErrorCode(tErrorCode);
          setUpMockAuthApiSignUpThrows(tDioException);

          // when
          final call = dataSource.signUp;

          // then
          await expectLater(
            () => call(email: tEmail, password: tPassword, name: tName),
            throwsA(AuthFailure(tAuthFailureType, tDioException)),
          );
        },
      );
    }

    test(
      '''
      GIVEN the API rejects the request with an error code
            that the app does not know about
      WHEN signUp is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        final tDioException = buildDioExceptionWithErrorCode('signup_disabled');
        setUpMockAuthApiSignUpThrows(tDioException);

        // when
        final call = dataSource.signUp;

        // then
        await expectLater(
          () => call(email: tEmail, password: tPassword, name: tName),
          throwsA(ServerFailure(tDioException)),
        );
      },
    );

    test(
      '''
      GIVEN the request never gets a response, as when the device is offline
      WHEN signUp is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        final tDioException = buildDioExceptionWithoutResponse();
        setUpMockAuthApiSignUpThrows(tDioException);

        // when
        final call = dataSource.signUp;

        // then
        await expectLater(
          () => call(email: tEmail, password: tPassword, name: tName),
          throwsA(ServerFailure(tDioException)),
        );
      },
    );
  });

  group('signOut', () {
    test(
      '''
      GIVEN the API signs the user out
      WHEN signOut is called
      THEN the API is asked to sign out exactly once
      AND signOut completes without throwing''',
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
      GIVEN the API fails to sign the user out
      WHEN signOut is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        final tDioException = buildDioExceptionWithoutResponse();
        when(() => mockAuthApi.signOut()).thenThrow(tDioException);

        // when
        final call = dataSource.signOut;

        // then
        await expectLater(call, throwsA(ServerFailure(tDioException)));
      },
    );

    test(
      '''
      GIVEN the API fails to sign the user out with an error code
            that would be an AuthFailure anywhere else
      WHEN signOut is called
      THEN a ServerFailure is thrown all the same,
           because signing out has no failures of its own''',
      () async {
        // given
        final tDioException = buildDioExceptionWithErrorCode(
          'over_request_rate_limit',
        );
        when(() => mockAuthApi.signOut()).thenThrow(tDioException);

        // when
        final call = dataSource.signOut;

        // then
        await expectLater(call, throwsA(ServerFailure(tDioException)));
      },
    );
  });
}
