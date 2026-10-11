import 'user.dart';

sealed class const SignUpResult();

final class const SignedUp(final User user) extends SignUpResult;

final class const ConfirmationRequired() extends SignUpResult;
