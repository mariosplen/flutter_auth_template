const minPasswordLength = 6;

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool isValidEmail(String email) => _emailPattern.hasMatch(email);

bool isLongEnoughPassword(String password) =>
    password.length >= minPasswordLength;
