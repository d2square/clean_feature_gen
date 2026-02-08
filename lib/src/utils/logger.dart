import 'dart:io';

/// Simple logger with colored output for the CLI.
class Logger {
  final bool verbose;

  const Logger({this.verbose = false});

  void info(String message) {
    stdout.writeln('  \x1B[36mℹ\x1B[0m $message');
  }

  void success(String message) {
    stdout.writeln('  \x1B[32m✓\x1B[0m $message');
  }

  void warning(String message) {
    stdout.writeln('  \x1B[33m⚠\x1B[0m $message');
  }

  void error(String message) {
    stderr.writeln('  \x1B[31m✗\x1B[0m $message');
  }

  void created(String filePath) {
    stdout.writeln('  \x1B[32m+\x1B[0m $filePath');
  }

  void skipped(String filePath) {
    if (verbose) {
      stdout.writeln('  \x1B[90m⊘\x1B[0m $filePath (already exists)');
    }
  }

  void header(String title) {
    stdout.writeln('');
    stdout.writeln('\x1B[1m$title\x1B[0m');
    stdout.writeln('${'─' * title.length}');
  }

  void newLine() {
    stdout.writeln('');
  }

  void debug(String message) {
    if (verbose) {
      stdout.writeln('  \x1B[90m🔍 $message\x1B[0m');
    }
  }

  void summary(int filesCreated, int filesSkipped, String featureName) {
    newLine();
    stdout.writeln(
      '\x1B[1m\x1B[32m🎉 Feature "$featureName" generated successfully!\x1B[0m',
    );
    stdout.writeln('   $filesCreated files created, $filesSkipped files skipped');
    newLine();
  }
}
