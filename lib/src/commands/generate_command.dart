import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:yaml/yaml.dart';
import '../models/feature_config.dart';
import '../generator.dart';
import '../utils/logger.dart';

/// CLI command to generate a feature from YAML config or inline flags.
class GenerateCommand extends Command<void> {
  /// Creates a new [GenerateCommand].
  GenerateCommand() {
    argParser
      ..addOption('config',
          abbr: 'c',
          help: 'Path to YAML configuration file.')
      ..addOption('name',
          abbr: 'n',
          help: 'Feature name in snake_case (used when no config file).')
      ..addOption('state-management',
          abbr: 's',
          allowed: ['bloc', 'cubit'],
          defaultsTo: 'bloc',
          help: 'State management approach.')
      ..addFlag('has-api',
          defaultsTo: true,
          help: 'Whether the feature makes API calls.')
      ..addOption('api-base',
          help: 'Base API endpoint path.')
      ..addFlag('generate-tests',
          defaultsTo: true,
          help: 'Generate unit test stubs.')
      ..addFlag('generate-di',
          defaultsTo: true,
          help: 'Generate dependency injection setup.')
      ..addFlag('use-freezed',
          defaultsTo: false,
          help: 'Generate Freezed-compatible models.')
      ..addFlag('local-data-source',
          defaultsTo: false,
          help: 'Include local data source for caching.')
      ..addOption('output',
          abbr: 'o',
          help: 'Custom output path (relative to project root).')
      ..addFlag('overwrite',
          defaultsTo: false,
          help: 'Overwrite existing files.')
      ..addFlag('verbose',
          abbr: 'v',
          defaultsTo: false,
          help: 'Show verbose output.');
  }

  @override
  String get name => 'generate';

  @override
  String get description =>
      'Generate a complete Clean Architecture feature module.';

  @override
  Future<void> run() async {
    final results = argResults!;
    final logger = Logger(verbose: results['verbose'] as bool);

    FeatureConfig config;

    if (results['config'] != null) {
      // Load from YAML file
      final configPath = results['config'] as String;
      final file = File(configPath);

      if (!file.existsSync()) {
        logger.error('Config file not found: $configPath');
        exit(1);
      }

      try {
        final yamlContent = file.readAsStringSync();
        final yamlMap = loadYaml(yamlContent);
        config = FeatureConfig.fromYaml(
            Map<String, dynamic>.from(yamlMap as YamlMap));
      } catch (e) {
        logger.error('Failed to parse config: $e');
        exit(1);
      }
    } else if (results['name'] != null) {
      // Create from inline flags
      config = FeatureConfig(
        name: results['name'] as String,
        stateManagement: StateManagement.fromString(
            results['state-management'] as String),
        hasApi: results['has-api'] as bool,
        apiBase: results['api-base'] as String?,
        generateTests: results['generate-tests'] as bool,
        generateDi: results['generate-di'] as bool,
        useFreezed: results['use-freezed'] as bool,
        hasLocalDataSource: results['local-data-source'] as bool,
        basePath: results['output'] as String?,
      );
    } else {
      logger.error(
          'Provide either --config <path> or --name <feature_name>');
      printUsage();
      exit(1);
    }

    // Detect project root
    final projectRoot = _findProjectRoot();
    if (projectRoot == null) {
      logger.error(
          'Could not find Flutter project root (no pubspec.yaml found).');
      logger.info('Run this command from within a Flutter project directory.');
      exit(1);
    }

    final generator = FeatureGenerator(
      config: config,
      projectRoot: projectRoot,
      overwrite: results['overwrite'] as bool,
      logger: logger,
    );

    try {
      await generator.generate();
    } catch (e) {
      logger.error('Generation failed: $e');
      exit(1);
    }
  }

  String? _findProjectRoot() {
    var dir = Directory.current;
    while (true) {
      if (File('${dir.path}/pubspec.yaml').existsSync()) {
        return dir.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) return null;
      dir = parent;
    }
  }
}
