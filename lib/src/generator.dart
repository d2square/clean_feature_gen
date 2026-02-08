import 'dart:io';
import 'package:path/path.dart' as p;

import 'models/feature_config.dart';
import 'templates/entity_template.dart';
import 'templates/model_template.dart';
import 'templates/repository_template.dart';
import 'templates/datasource_template.dart';
import 'templates/usecase_template.dart';
import 'templates/bloc_template.dart';
import 'templates/screen_template.dart';
import 'templates/di_route_template.dart';
import 'templates/test_template.dart';
import 'utils/logger.dart';
import 'utils/string_utils.dart';

/// Main generator that orchestrates the creation of all feature files.
///
/// Usage:
/// ```dart
/// final generator = FeatureGenerator(
///   config: myConfig,
///   projectRoot: '/path/to/flutter/project',
/// );
/// await generator.generate();
/// ```
class FeatureGenerator {
  final FeatureConfig config;
  final String projectRoot;
  final Logger logger;
  final bool overwrite;

  int _filesCreated = 0;
  int _filesSkipped = 0;

  FeatureGenerator({
    required this.config,
    required this.projectRoot,
    this.overwrite = false,
    Logger? logger,
  }) : logger = logger ?? const Logger();

  /// Generate all files for the feature.
  Future<void> generate() async {
    // Validate
    final errors = config.validate();
    if (errors.isNotEmpty) {
      logger.error('Configuration errors:');
      for (final e in errors) {
        logger.error('  - $e');
      }
      throw ArgumentError('Invalid feature configuration.');
    }

    final featurePath = _featurePath();
    logger.header('Generating feature: ${config.name}');
    logger.info('Output: $featurePath');
    logger.info('State management: ${config.stateManagement.name}');
    logger.newLine();

    // Generate domain layer
    logger.info('📁 Domain Layer');
    await _generateDomainLayer(featurePath);

    // Generate data layer
    logger.info('📁 Data Layer');
    await _generateDataLayer(featurePath);

    // Generate presentation layer
    logger.info('📁 Presentation Layer');
    await _generatePresentationLayer(featurePath);

    // Generate DI
    if (config.generateDi) {
      logger.info('📁 Dependency Injection');
      await _generateDi(featurePath);
    }

    // Generate routes
    if (config.generateRoutes) {
      logger.info('📁 Routes');
      await _generateRoutes(featurePath);
    }

    // Generate tests
    if (config.generateTests) {
      logger.info('📁 Tests');
      await _generateTests();
    }

    // Generate barrel file
    await _generateBarrelFile(featurePath);

    logger.summary(_filesCreated, _filesSkipped, config.name);
  }

  // ─── Domain Layer ────────────────────────────────────────

  Future<void> _generateDomainLayer(String featurePath) async {
    final domainPath = p.join(featurePath, 'domain');

    // Entities
    final entityTemplate = const EntityTemplate();
    for (final model in config.models) {
      await _writeFile(
        p.join(domainPath, 'entities', '${model.name.toSnakeCase}_entity.dart'),
        entityTemplate.generate(model, config),
      );
    }

    // Failure class
    final usecaseTemplate = const UsecaseTemplate();
    if (config.usecases.any((u) => u.useEither)) {
      await _writeFile(
        p.join(domainPath, 'entities', 'failure.dart'),
        usecaseTemplate.generateFailure(),
      );
    }

    // Repository interface
    final repoTemplate = const RepositoryTemplate();
    await _writeFile(
      p.join(domainPath, 'repositories',
          '${config.name.toSnakeCase}_repository.dart'),
      repoTemplate.generateInterface(config),
    );

    // Use cases
    for (final usecase in config.usecases) {
      await _writeFile(
        p.join(domainPath, 'usecases',
            '${usecase.name.toSnakeCase}_usecase.dart'),
        usecaseTemplate.generate(usecase, config),
      );
    }
  }

  // ─── Data Layer ──────────────────────────────────────────

  Future<void> _generateDataLayer(String featurePath) async {
    final dataPath = p.join(featurePath, 'data');

    // Models
    final modelTemplate = const ModelTemplate();
    for (final model in config.models) {
      await _writeFile(
        p.join(dataPath, 'models', '${model.name.toSnakeCase}_model.dart'),
        modelTemplate.generate(model, config),
      );
    }

    // Data sources
    final dsTemplate = const DataSourceTemplate();
    if (config.hasApi) {
      await _writeFile(
        p.join(dataPath, 'datasources',
            '${config.name.toSnakeCase}_remote_data_source.dart'),
        dsTemplate.generateRemote(config),
      );
    }
    if (config.hasLocalDataSource) {
      await _writeFile(
        p.join(dataPath, 'datasources',
            '${config.name.toSnakeCase}_local_data_source.dart'),
        dsTemplate.generateLocal(config),
      );
    }

    // Repository implementation
    final repoTemplate = const RepositoryTemplate();
    await _writeFile(
      p.join(dataPath, 'repositories',
          '${config.name.toSnakeCase}_repository_impl.dart'),
      repoTemplate.generateImplementation(config),
    );
  }

  // ─── Presentation Layer ──────────────────────────────────

  Future<void> _generatePresentationLayer(String featurePath) async {
    final presPath = p.join(featurePath, 'presentation');
    final blocTemplate = const BlocTemplate();
    final snakeName = config.name.toSnakeCase;

    // BLoC or Cubit
    if (config.stateManagement == StateManagement.bloc) {
      await _writeFile(
        p.join(presPath, 'bloc', '${snakeName}_bloc.dart'),
        blocTemplate.generateBloc(config),
      );
      await _writeFile(
        p.join(presPath, 'bloc', '${snakeName}_event.dart'),
        blocTemplate.generateEvents(config),
      );
    } else {
      await _writeFile(
        p.join(presPath, 'cubit', '${snakeName}_cubit.dart'),
        blocTemplate.generateCubit(config),
      );
    }

    // State (shared between bloc and cubit)
    final stateDir = config.stateManagement == StateManagement.bloc
        ? 'bloc'
        : 'cubit';
    // State file always goes in 'bloc' folder for both (shared)
    await _writeFile(
      p.join(presPath, 'bloc', '${snakeName}_state.dart'),
      blocTemplate.generateState(config),
    );

    // Screens
    final screenTemplate = const ScreenTemplate();
    for (final screen in config.screens) {
      await _writeFile(
        p.join(presPath, 'screens', '${screen.name.toSnakeCase}.dart'),
        screenTemplate.generate(screen, config),
      );

      // Create empty widgets directory for each screen
      final widgetsDir = Directory(
          p.join(presPath, 'widgets'));
      if (!widgetsDir.existsSync()) {
        widgetsDir.createSync(recursive: true);
        await _writeFile(
          p.join(presPath, 'widgets', '.gitkeep'),
          '',
        );
      }
    }
  }

  // ─── DI & Routes ─────────────────────────────────────────

  Future<void> _generateDi(String featurePath) async {
    final diTemplate = const DiTemplate();
    await _writeFile(
      p.join(featurePath, 'di', '${config.name.toSnakeCase}_injection.dart'),
      diTemplate.generate(config),
    );
  }

  Future<void> _generateRoutes(String featurePath) async {
    final routeTemplate = const RouteTemplate();
    await _writeFile(
      p.join(featurePath, 'routes', '${config.name.toSnakeCase}_routes.dart'),
      routeTemplate.generate(config),
    );
  }

  // ─── Tests ───────────────────────────────────────────────

  Future<void> _generateTests() async {
    final testPath = p.join(
        projectRoot, 'test', 'features', config.name.toSnakeCase);
    final testTemplate = const TestTemplate();

    await _writeFile(
      p.join(testPath, '${config.name.toSnakeCase}_bloc_test.dart'),
      testTemplate.generateBlocTest(config),
    );

    await _writeFile(
      p.join(testPath, '${config.name.toSnakeCase}_repository_test.dart'),
      testTemplate.generateRepositoryTest(config),
    );
  }

  // ─── Barrel File ─────────────────────────────────────────

  Future<void> _generateBarrelFile(String featurePath) async {
    final buffer = StringBuffer();
    final snake = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Barrel file for feature "${config.name}"'));

    buffer.writeln('// Domain');
    for (final model in config.models) {
      buffer.writeln(
          "export 'domain/entities/${model.name.toSnakeCase}_entity.dart';");
    }
    if (config.usecases.any((u) => u.useEither)) {
      buffer.writeln("export 'domain/entities/failure.dart';");
    }
    buffer.writeln("export 'domain/repositories/${snake}_repository.dart';");
    for (final usecase in config.usecases) {
      buffer.writeln(
          "export 'domain/usecases/${usecase.name.toSnakeCase}_usecase.dart';");
    }
    buffer.writeln('');

    buffer.writeln('// Data');
    for (final model in config.models) {
      buffer.writeln(
          "export 'data/models/${model.name.toSnakeCase}_model.dart';");
    }
    buffer.writeln(
        "export 'data/repositories/${snake}_repository_impl.dart';");
    buffer.writeln('');

    buffer.writeln('// Presentation');
    if (config.stateManagement == StateManagement.bloc) {
      buffer.writeln("export 'presentation/bloc/${snake}_bloc.dart';");
      buffer.writeln("export 'presentation/bloc/${snake}_event.dart';");
    } else {
      buffer.writeln("export 'presentation/cubit/${snake}_cubit.dart';");
    }
    buffer.writeln("export 'presentation/bloc/${snake}_state.dart';");
    for (final screen in config.screens) {
      buffer.writeln(
          "export 'presentation/screens/${screen.name.toSnakeCase}.dart';");
    }

    await _writeFile(
      p.join(featurePath, '${snake}.dart'),
      buffer.toString(),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  String _featurePath() {
    final base = config.basePath ?? 'lib/features';
    return p.join(projectRoot, base, config.name.toSnakeCase);
  }

  Future<void> _writeFile(String filePath, String content) async {
    final file = File(filePath);

    if (file.existsSync() && !overwrite) {
      _filesSkipped++;
      logger.skipped(p.relative(filePath, from: projectRoot));
      return;
    }

    final dir = file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    await file.writeAsString(content);
    _filesCreated++;
    logger.created(p.relative(filePath, from: projectRoot));
  }
}
