import 'package:args/command_runner.dart';
import '../utils/logger.dart';

/// CLI command to list available templates and generated file structure.
class ListTemplatesCommand extends Command<void> {
  @override
  String get name => 'list';

  @override
  String get description =>
      'Show the file structure that will be generated for a feature.';

  @override
  Future<void> run() async {
    final logger = const Logger();

    logger.header('Clean Feature Generator — File Structure');
    logger.newLine();

    print('''
  lib/features/<feature_name>/
  │
  ├── domain/                          # Pure Dart — no dependencies
  │   ├── entities/
  │   │   ├── <model>_entity.dart      # Domain entity (copyWith, equality)
  │   │   └── failure.dart             # Failure types for error handling
  │   │
  │   ├── repositories/
  │   │   └── <feature>_repository.dart # Abstract repository interface
  │   │
  │   └── usecases/
  │       └── <usecase>_usecase.dart    # Business logic operations
  │
  ├── data/                            # External dependencies
  │   ├── models/
  │   │   └── <model>_model.dart       # DTO with JSON serialization
  │   │
  │   ├── datasources/
  │   │   ├── <feature>_remote_data_source.dart  # API calls
  │   │   └── <feature>_local_data_source.dart   # Local cache (optional)
  │   │
  │   └── repositories/
  │       └── <feature>_repository_impl.dart     # Repository implementation
  │
  ├── presentation/                    # Flutter UI layer
  │   ├── bloc/                        # (or cubit/)
  │   │   ├── <feature>_bloc.dart      # BLoC with event handlers
  │   │   ├── <feature>_event.dart     # Sealed event classes
  │   │   └── <feature>_state.dart     # State with status enum
  │   │
  │   ├── screens/
  │   │   └── <screen>.dart            # Screen with BLoC integration
  │   │
  │   └── widgets/                     # Reusable widgets directory
  │
  ├── di/
  │   └── <feature>_injection.dart     # Dependency injection setup
  │
  ├── routes/
  │   └── <feature>_routes.dart        # Route configuration
  │
  └── <feature>.dart                   # Barrel file (exports everything)

  test/features/<feature_name>/
  ├── <feature>_bloc_test.dart         # BLoC unit tests
  └── <feature>_repository_test.dart   # Repository unit tests
''');

    logger.info('To generate a feature, run:');
    logger.info('  clean_feature_gen generate --config feature_config.yaml');
    logger.info('  clean_feature_gen generate --name my_feature');
    logger.newLine();
    logger.info('To create a sample config:');
    logger.info('  clean_feature_gen init');
  }
}
