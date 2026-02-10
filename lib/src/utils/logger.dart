import 'dart:io';

/// Simple logger with colored terminal output for the CLI.
///
/// Supports info, success, warning, error, and debug messages
/// with ANSI color codes. Set [verbose] to `true` for debug output.
class Logger {
  /// Creates a new [Logger] instance.
  const Logger({this.verbose = false});

  /// Whether to show verbose/debug output.
  final bool verbose;

  /// Log an informational message (cyan).
  void info(String message) {
    stdout.writeln('  \x1B[36mℹ\x1B[0m $message');
  }

  /// Log a success message (green checkmark).
  void success(String message) {
    stdout.writeln('  \x1B[32m✓\x1B[0m $message');
  }

  /// Log a warning message (yellow).
  void warning(String message) {
    stdout.writeln('  \x1B[33m⚠\x1B[0m $message');
  }

  /// Log an error message (red) to stderr.
  void error(String message) {
    stderr.writeln('  \x1B[31m✗\x1B[0m $message');
  }

  /// Log a file creation event (green plus).
  void created(String filePath) {
    stdout.writeln('  \x1B[32m+\x1B[0m $filePath');
  }

  /// Log a skipped file (only shown in verbose mode).
  void skipped(String filePath) {
    if (verbose) {
      stdout.writeln('  \x1B[90m⊘\x1B[0m $filePath (already exists)');
    }
  }

  /// Print a section header with underline.
  void header(String title) {
    stdout.writeln('');
    stdout.writeln('\x1B[1m$title\x1B[0m');
    final line = '─' * title.length;
    stdout.writeln(line);
  }

  /// Print a blank line.
  void newLine() {
    stdout.writeln('');
  }

  /// Log a debug message (only shown in verbose mode).
  void debug(String message) {
    if (verbose) {
      stdout.writeln('  \x1B[90m🔍 $message\x1B[0m');
    }
  }

  /// Print a generation summary with file counts.
  void summary(int filesCreated, int filesSkipped, String featureName) {
    newLine();
    stdout.writeln(
      '\x1B[1m\x1B[32m🎉 Feature "$featureName" generated successfully!\x1B[0m',
    );
    stdout.writeln('   $filesCreated files created, $filesSkipped files skipped');
    newLine();
  }
}
