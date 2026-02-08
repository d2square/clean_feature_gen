#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:clean_feature_gen/clean_feature_gen.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner<void>(
    'clean_feature_gen',
    'Generate complete Clean Architecture feature modules for Flutter.\n'
        'Supports BLoC/Cubit state management with full data, domain, and presentation layers.',
  )
    ..addCommand(GenerateCommand())
    ..addCommand(InitCommand())
    ..addCommand(ListTemplatesCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    stderr.writeln('${e.message}\n');
    stderr.writeln(runner.usage);
    exit(64);
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
