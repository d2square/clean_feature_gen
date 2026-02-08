import 'dart:io';
import 'package:args/command_runner.dart';
import '../utils/logger.dart';

/// CLI command to initialize a sample YAML config file.
class InitCommand extends Command<void> {
  @override
  String get name => 'init';

  @override
  String get description =>
      'Create a sample feature configuration YAML file.';

  InitCommand() {
    argParser.addOption('output',
        abbr: 'o',
        defaultsTo: 'feature_config.yaml',
        help: 'Output file path for the sample config.');
  }

  @override
  Future<void> run() async {
    final logger = const Logger();
    final outputPath = argResults!['output'] as String;
    final file = File(outputPath);

    if (file.existsSync()) {
      logger.warning('File already exists: $outputPath');
      logger.info('Use a different path with --output <path>');
      return;
    }

    await file.writeAsString(_sampleConfig);
    logger.success('Created sample config: $outputPath');
    logger.newLine();
    logger.info('Edit the config file, then run:');
    logger.info('  clean_feature_gen generate --config $outputPath');
  }

  static const _sampleConfig = '''# ═══════════════════════════════════════════════════════════
# Clean Feature Generator — Configuration
# ═══════════════════════════════════════════════════════════
#
# This file defines a complete Clean Architecture feature module.
# Edit the values below and run:
#   clean_feature_gen generate --config feature_config.yaml
#

# ─── Feature Name (snake_case) ──────────────────────────
feature: user_profile

# ─── State Management ───────────────────────────────────
# Options: bloc, cubit
state_management: bloc

# ─── API Configuration ──────────────────────────────────
has_api: true
api_base: /api/v1/users

# ─── Generation Options ────────────────────────────────
generate_tests: true
generate_di: true
generate_routes: true

# ─── Serialization Strategy ─────────────────────────────
# use_freezed: true          # Generate Freezed classes (needs freezed package)
use_json_serializable: true   # Generate json_serializable annotations

# ─── Data Sources ───────────────────────────────────────
has_local_data_source: false   # Generate local cache data source

# ─── Custom Output Path (optional) ─────────────────────
# base_path: lib/features     # Default: lib/features

# ─── Models ─────────────────────────────────────────────
# Define your data models. Each generates:
#   - Entity (domain layer, pure Dart)
#   - Model/DTO (data layer, with JSON)
#   - Mapper between entity and model
models:
  - name: UserProfile
    copy_with: true
    equality: true
    fields:
      - name: id
        type: int
      - name: email
        type: String
      - name: fullName
        type: String
        json_key: full_name
      - name: avatarUrl
        type: String?
        json_key: avatar_url
      - name: isActive
        type: bool
        default: "true"
        json_key: is_active
      - name: createdAt
        type: DateTime
        json_key: created_at

# ─── Use Cases ──────────────────────────────────────────
# Each generates:
#   - UseCase class (domain)
#   - Repository method (domain interface + data impl)
#   - DataSource method
#   - BLoC event + handler (or Cubit method)
usecases:
  - name: GetUserProfile
    return_type: UserProfile
    params:
      - name: userId
        type: int
  - name: UpdateUserProfile
    return_type: UserProfile
    params:
      - name: profile
        type: UserProfile
  - name: DeleteUserProfile
    return_type: void
    params:
      - name: userId
        type: int

# ─── Screens ────────────────────────────────────────────
# Each generates a complete screen widget with:
#   - BLoC integration
#   - Loading/error/empty states
#   - Route configuration
screens:
  - name: UserProfileScreen
    type: stateless
    has_app_bar: true
    loading_state: true
    error_state: true
  - name: EditProfileScreen
    type: stateful
    has_app_bar: true
    pull_to_refresh: false
''';
}
