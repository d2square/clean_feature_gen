/// Clean Feature Generator
///
/// A powerful CLI tool and library for generating complete Clean Architecture
/// feature modules in Flutter with BLoC/Cubit support.
///
/// ## Quick Start
///
/// ```bash
/// # Initialize config in your Flutter project
/// clean_feature_gen init
///
/// # Generate a feature from YAML config
/// clean_feature_gen generate --config feature.yaml
///
/// # Generate with inline options
/// clean_feature_gen generate --name login --state-management bloc --has-api
/// ```
library clean_feature_gen;

export 'src/models/feature_config.dart';
export 'src/models/model_definition.dart';
export 'src/models/usecase_definition.dart';
export 'src/models/screen_definition.dart';
export 'src/generator.dart';
export 'src/commands/generate_command.dart';
export 'src/commands/init_command.dart';
export 'src/commands/list_templates_command.dart';
export 'src/utils/string_utils.dart';
export 'src/utils/logger.dart';
