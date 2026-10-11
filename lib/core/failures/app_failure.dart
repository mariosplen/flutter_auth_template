abstract class const AppFailure(final Object cause) implements Exception;

class const NetworkFailure(super.cause) extends AppFailure;
class const UnexpectedFailure(super.cause) extends AppFailure;
