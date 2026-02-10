/// Defines a parameter for a use case.
class ParamDefinition {
  /// Creates a new [ParamDefinition].
  const ParamDefinition({required this.name, required this.type});

  /// Create from a parsed YAML map.
  factory ParamDefinition.fromYaml(Map<String, dynamic> yaml) {
    return ParamDefinition(
      name: yaml['name'] as String,
      type: yaml['type'] as String,
    );
  }

  /// Parameter name in camelCase.
  final String name;

  /// Parameter Dart type.
  final String type;
}

/// Defines a use case (business logic operation).
///
/// Each use case generates:
/// - A UseCase class in the domain layer
/// - A corresponding method in the Repository interface
/// - A corresponding method in the Repository implementation
/// - A corresponding method in the DataSource
/// - An event/handler in the BLoC (or method in Cubit)
class UsecaseDefinition {
  /// Creates a new [UsecaseDefinition].
  const UsecaseDefinition({
    required this.name,
    this.returnType = 'void',
    this.params = const [],
    this.isStream = false,
    this.useEither = true,
  });

  /// Create from a parsed YAML map.
  factory UsecaseDefinition.fromYaml(Map<String, dynamic> yaml) {
    final params = <ParamDefinition>[];
    if (yaml['params'] != null) {
      for (final p in (yaml['params'] as List)) {
        if (p is Map<String, dynamic>) {
          params.add(ParamDefinition.fromYaml(p));
        }
      }
    }

    return UsecaseDefinition(
      name: yaml['name'] as String,
      returnType: yaml['return_type'] as String? ?? 'void',
      params: params,
      isStream: yaml['is_stream'] as bool? ?? false,
      useEither: yaml['use_either'] as bool? ?? true,
    );
  }

  /// Use case name in PascalCase (e.g., 'GetUserProfile').
  final String name;

  /// Return type (e.g., `User`, `void`, `bool`).
  final String returnType;

  /// Parameters for this use case.
  final List<ParamDefinition> params;

  /// Whether this is a stream-based use case (e.g., real-time data).
  final bool isStream;

  /// Whether to wrap return type in a result tuple.
  final bool useEither;

  /// Whether this use case has parameters.
  bool get hasParams => params.isNotEmpty;

  /// Whether the use case returns void.
  bool get isVoid => returnType == 'void';

  /// Validate this use case definition.
  List<String> validate() {
    final errors = <String>[];
    if (name.isEmpty) errors.add('UseCase name cannot be empty.');
    if (!RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(name)) {
      errors.add('UseCase name must be PascalCase. Got: "$name"');
    }
    return errors;
  }
}
