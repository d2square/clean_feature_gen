/// Defines a single field within a model.
class FieldDefinition {
  /// Creates a new [FieldDefinition].
  const FieldDefinition({
    required this.name,
    required this.type,
    this.defaultValue,
    this.jsonKey,
    this.isRequired = true,
  });

  /// Create from a parsed YAML map.
  factory FieldDefinition.fromYaml(Map<String, dynamic> yaml) {
    return FieldDefinition(
      name: yaml['name'] as String,
      type: yaml['type'] as String,
      defaultValue: yaml['default'] as String?,
      jsonKey: yaml['json_key'] as String?,
      isRequired: yaml['required'] as bool? ?? true,
    );
  }

  /// Field name in camelCase (e.g., 'firstName').
  final String name;

  /// Dart type (e.g., `String`, `int`, `DateTime?`).
  final String type;

  /// Default value as a string expression (e.g., "'unknown'", '0', 'false').
  final String? defaultValue;

  /// JSON key name if different from field name (e.g., 'first_name').
  final String? jsonKey;

  /// Whether this field is required in constructors.
  final bool isRequired;

  /// Whether this type is nullable.
  bool get isNullable => type.endsWith('?');

  /// The base type without nullability suffix.
  String get baseType => isNullable ? type.substring(0, type.length - 1) : type;

  /// Whether this is a primitive Dart type.
  bool get isPrimitive =>
      ['String', 'int', 'double', 'bool', 'num'].contains(baseType);

  /// Whether this is a collection type.
  bool get isList => type.startsWith('List<');

  /// Whether this is a map type.
  bool get isMap => type.startsWith('Map<');

  /// Validate this field definition.
  List<String> validate() {
    final errors = <String>[];
    if (name.isEmpty) errors.add('Field name cannot be empty.');
    if (type.isEmpty) errors.add('Field type cannot be empty for field "$name".');
    return errors;
  }
}

/// Defines a data model (entity + DTO).
///
/// A single ModelDefinition generates:
/// - An entity class in the domain layer (pure Dart, no dependencies)
/// - A model/DTO class in the data layer (with JSON serialization)
/// - Mapper extension between entity and model
class ModelDefinition {
  /// Creates a new [ModelDefinition].
  const ModelDefinition({
    required this.name,
    required this.fields,
    this.generateCopyWith = true,
    this.generateEquality = true,
    this.generateToString = true,
  });

  /// Create from a parsed YAML map.
  factory ModelDefinition.fromYaml(Map<String, dynamic> yaml) {
    final fields = <FieldDefinition>[];
    if (yaml['fields'] != null) {
      for (final f in (yaml['fields'] as List)) {
        if (f is Map<String, dynamic>) {
          fields.add(FieldDefinition.fromYaml(f));
        } else if (f is String) {
          final parts = f.split(':').map((e) => e.trim()).toList();
          if (parts.length == 2) {
            fields.add(FieldDefinition(name: parts[0], type: parts[1]));
          }
        }
      }
    }

    return ModelDefinition(
      name: yaml['name'] as String,
      fields: fields,
      generateCopyWith: yaml['copy_with'] as bool? ?? true,
      generateEquality: yaml['equality'] as bool? ?? true,
      generateToString: yaml['to_string'] as bool? ?? true,
    );
  }

  /// Model name in PascalCase (e.g., 'UserProfile').
  final String name;

  /// Fields for this model.
  final List<FieldDefinition> fields;

  /// Whether to generate copyWith method.
  final bool generateCopyWith;

  /// Whether to generate equality (== and hashCode).
  final bool generateEquality;

  /// Whether to generate toString override.
  final bool generateToString;

  /// Validate this model definition.
  List<String> validate() {
    final errors = <String>[];
    if (name.isEmpty) errors.add('Model name cannot be empty.');
    if (!RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(name)) {
      errors.add('Model name must be PascalCase. Got: "$name"');
    }
    if (fields.isEmpty) errors.add('Model "$name" must have at least one field.');
    for (final field in fields) {
      errors.addAll(field.validate());
    }
    return errors;
  }
}
