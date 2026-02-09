class Validators {

  Validators._();

  static final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  static final emailRegex = RegExp(
    r"^[a-zA-Z0-9](\.?[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]{0,63})@[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,63})+$"
  );
  static final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,64}$'
  );


  /// Validates a username according to defined rules:
  /// - Must not be null or empty.
  /// - Length must be between 3 and 16 characters.
  /// - Can only contain letters, numbers, and underscores.
  /// Returns an error message string if invalid, or null if valid.
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required.';
    }
    if (value.length < 3 || value.length > 16) {
      return 'Username must be between 3 and 16 characters.';
    }
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores.';
    }
    return null;
  }

  /// Validates a display name according to defined rules:
  /// - Must not be null or empty.
  /// - Length must be between 3 and 16 characters.
  /// Returns an error message string if invalid, or null if valid.
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required.';
    }
    if (value.length < 3 || value.length > 16) {
      return 'Display name must be between 3 and 16 characters.';
    }
    return null;
  }

  /// Validates an email address according to defined rules:
  /// - Must not be null or empty.
  /// - Must match a basic email pattern (local-part@domain).
  /// - Must not exceed 254 characters in length.
  /// Returns an error message string if invalid, or null if valid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    if (!emailRegex.hasMatch(value) || value.length > 254) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates a password according to defined rules:
  /// - Must not be null or empty.
  /// - Must be between 6 and 64 characters in length.
  /// - Must contain at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character.
  /// Returns an error message string if invalid, or null if valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6 || value.length > 64) {
      return 'Password must be between 6 and 64 characters long.';
    }
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character.';
    }
    return null;
  }
}