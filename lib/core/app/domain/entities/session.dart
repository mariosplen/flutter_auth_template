import 'package:equatable/equatable.dart';

/// The Supabase tokens of the signed-in user. There is a session exactly
/// when the user is signed in.
class const Session({
  required final String accessToken,
  required final String refreshToken,
}) extends Equatable {
  @override
  List<Object> get props => [accessToken, refreshToken];
}
