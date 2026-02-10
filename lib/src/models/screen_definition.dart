/// Screen widget type.
enum ScreenType {
  /// StatelessWidget.
  stateless,

  /// StatefulWidget.
  stateful;

  /// Parse from a string value.
  static ScreenType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'stateful':
        return ScreenType.stateful;
      case 'stateless':
      default:
        return ScreenType.stateless;
    }
  }
}

/// Defines a screen/page in the presentation layer.
///
/// Each screen generates:
/// - A screen widget file
/// - A corresponding widgets directory
/// - Route configuration entry
class ScreenDefinition {
  /// Creates a new [ScreenDefinition].
  const ScreenDefinition({
    required this.name,
    this.type = ScreenType.stateless,
    this.hasOwnBloc = true,
    this.hasAppBar = true,
    this.hasPullToRefresh = false,
    this.hasLoadingState = true,
    this.hasErrorState = true,
    this.hasEmptyState = true,
  });

  /// Create from a parsed YAML map.
  factory ScreenDefinition.fromYaml(Map<String, dynamic> yaml) {
    return ScreenDefinition(
      name: yaml['name'] as String,
      type: yaml['type'] != null
          ? ScreenType.fromString(yaml['type'] as String)
          : ScreenType.stateless,
      hasOwnBloc: yaml['has_own_bloc'] as bool? ?? true,
      hasAppBar: yaml['has_app_bar'] as bool? ?? true,
      hasPullToRefresh: yaml['pull_to_refresh'] as bool? ?? false,
      hasLoadingState: yaml['loading_state'] as bool? ?? true,
      hasErrorState: yaml['error_state'] as bool? ?? true,
      hasEmptyState: yaml['empty_state'] as bool? ?? true,
    );
  }

  /// Screen name in PascalCase (e.g., 'UserProfileScreen').
  final String name;

  /// Whether stateless or stateful.
  final ScreenType type;

  /// Whether this screen has its own BLoC/Cubit.
  final bool hasOwnBloc;

  /// Whether to generate an AppBar.
  final bool hasAppBar;

  /// Whether this screen supports pull-to-refresh.
  final bool hasPullToRefresh;

  /// Whether to include a loading state widget.
  final bool hasLoadingState;

  /// Whether to include an error state widget.
  final bool hasErrorState;

  /// Whether to include an empty state widget.
  final bool hasEmptyState;

  /// Validate this screen definition.
  List<String> validate() {
    final errors = <String>[];
    if (name.isEmpty) errors.add('Screen name cannot be empty.');
    if (!RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(name)) {
      errors.add('Screen name must be PascalCase. Got: "$name"');
    }
    return errors;
  }
}
