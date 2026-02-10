import 'model_definition.dart';
import 'usecase_definition.dart';
import 'screen_definition.dart';

/// Supported state management approaches.
enum StateManagement {
  /// BLoC pattern with events and states.
  bloc,

  /// Cubit pattern with methods and states.
  cubit;

  /// Parse from a string value.
  static StateManagement fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bloc':
        return StateManagement.bloc;
      case 'cubit':
        return StateManagement.cubit;
      default:
        throw ArgumentError('Unsupported state management: $value. Use "bloc" or "cubit".');
    }
  }
}

/// Configuration for generating a complete feature module.
///
/// This is the primary configuration object that drives the entire
/// code generation process. It can be created programmatically or
/// parsed from a YAML file.
class FeatureConfig {
  /// Creates a new [FeatureConfig] with the given options.
  ///
  /// Only [name] is required. All other fields have sensible defaults.
  const FeatureConfig({
    required this.name,
    this.stateManagement = StateManagement.bloc,
    this.hasApi = true,
    this.apiBase,
    this.generateTests = true,
    this.generateDi = true,
    this.generateRoutes = true,
    this.useFreezed = false,
    this.useJsonSerializable = true,
    this.basePath,
    this.models = const [],
    this.usecases = const [],
    this.screens = const [],
    this.hasLocalDataSource = false,
    this.hasPagination = false,
    this.packageName,
  });

  /// Create from a parsed YAML map.
  factory FeatureConfig.fromYaml(Map<String, dynamic> yaml) {
    final models = <ModelDefinition>[];
    if (yaml['models'] != null) {
      for (final m in (yaml['models'] as List)) {
        models.add(ModelDefinition.fromYaml(m as Map<String, dynamic>));
      }
    }

    final usecases = <UsecaseDefinition>[];
    if (yaml['usecases'] != null) {
      for (final u in (yaml['usecases'] as List)) {
        usecases.add(UsecaseDefinition.fromYaml(u as Map<String, dynamic>));
      }
    }

    final screens = <ScreenDefinition>[];
    if (yaml['screens'] != null) {
      for (final s in (yaml['screens'] as List)) {
        screens.add(ScreenDefinition.fromYaml(s as Map<String, dynamic>));
      }
    }

    return FeatureConfig(
      name: yaml['feature'] as String,
      stateManagement: yaml['state_management'] != null
          ? StateManagement.fromString(yaml['state_management'] as String)
          : StateManagement.bloc,
      hasApi: yaml['has_api'] as bool? ?? true,
      apiBase: yaml['api_base'] as String?,
      generateTests: yaml['generate_tests'] as bool? ?? true,
      generateDi: yaml['generate_di'] as bool? ?? true,
      generateRoutes: yaml['generate_routes'] as bool? ?? true,
      useFreezed: yaml['use_freezed'] as bool? ?? false,
      useJsonSerializable: yaml['use_json_serializable'] as bool? ?? true,
      basePath: yaml['base_path'] as String?,
      models: models,
      usecases: usecases,
      screens: screens,
      hasLocalDataSource: yaml['has_local_data_source'] as bool? ?? false,
      hasPagination: yaml['has_pagination'] as bool? ?? false,
      packageName: yaml['package_name'] as String?,
    );
  }

  /// The feature name in snake_case (e.g., 'user_profile').
  final String name;

  /// State management approach: bloc or cubit.
  final StateManagement stateManagement;

  /// Whether this feature makes API calls.
  final bool hasApi;

  /// Base API endpoint path (e.g., '/api/v1/users').
  final String? apiBase;

  /// Whether to generate unit test stubs.
  final bool generateTests;

  /// Whether to generate dependency injection setup.
  final bool generateDi;

  /// Whether to generate route configuration.
  final bool generateRoutes;

  /// Whether to generate Freezed-compatible models.
  final bool useFreezed;

  /// Whether to generate JSON serialization code.
  final bool useJsonSerializable;

  /// Custom base path for feature output (relative to lib/).
  final String? basePath;

  /// Data models for this feature.
  final List<ModelDefinition> models;

  /// Use cases / business logic operations.
  final List<UsecaseDefinition> usecases;

  /// Screen/page definitions.
  final List<ScreenDefinition> screens;

  /// Whether to include a local data source (e.g., Hive/SharedPreferences).
  final bool hasLocalDataSource;

  /// Whether to include pagination support in the repository.
  final bool hasPagination;

  /// Package name for imports (auto-detected from pubspec.yaml if not set).
  final String? packageName;

  /// Validate the configuration and return any errors.
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Feature name cannot be empty.');
    }

    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
      errors.add(
          'Feature name must be snake_case (lowercase letters, numbers, underscores). Got: "$name"');
    }

    for (final model in models) {
      errors.addAll(model.validate());
    }

    for (final usecase in usecases) {
      errors.addAll(usecase.validate());
    }

    for (final screen in screens) {
      errors.addAll(screen.validate());
    }

    return errors;
  }
}
