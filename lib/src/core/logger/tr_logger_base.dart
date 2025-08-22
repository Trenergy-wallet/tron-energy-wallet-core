/// Base logging interface for the wallet core package.
///
/// This interface defines the contract for logging within the SDK.
/// Developers can provide their own implementation (e.g. console, file,
/// remote analytics, crash reporting).
///
/// Features:
/// - Support for different severity levels: info, warning, error, critical.
/// - Access to current log buffer and ability to clear it.
/// - Explicit [inTest] flag to simplify testing (e.g. redirecting to `print`).
///
abstract class TRLogger {
  /// Indicates if the logger is running in a test environment.
  /// Can be used to simplify test logging (e.g. plain prints).
  bool get inTest;

  /// Returns the current log buffer as a string.
  String get getLog;

  /// Clears the current log buffer.
  void cleanLog();

  /// Saves a regular informational message without prefix.
  void logInfoMessage(String method, Object line);

  /// Saves a warning message indicating something went wrong,
  /// but fallback logic worked.
  /// Example: a DTO assigned a default value for a missing required field.
  void logWarning(String method, Object line);

  /// Saves an error message.
  /// Use for recoverable errors during normal execution.
  void logError(
    String method,
    Object line, [
    Object? error,
    StackTrace? stacktrace,
  ]);

  /// Saves a critical error message.
  /// Use for unrecoverable errors that significantly affect app functionality.
  void logCriticalError(
    String method,
    Object line, [
    Object? error,
    StackTrace? stacktrace,
  ]);
}
