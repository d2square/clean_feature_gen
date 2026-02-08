import '../models/feature_config.dart';
import '../models/model_definition.dart';
import '../utils/string_utils.dart';

/// Generates data layer model (DTO) classes with JSON serialization.
class ModelTemplate {
  const ModelTemplate();

  String generate(ModelDefinition model, FeatureConfig config) {
    final buffer = StringBuffer();
    final snakeName = model.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Model: ${model.name}Model for feature "${config.name}"'));

    if (config.useFreezed) {
      buffer.writeln(_generateFreezedModel(model, snakeName));
    } else if (config.useJsonSerializable) {
      buffer.writeln(_generateJsonSerializableModel(model, snakeName, config));
    } else {
      buffer.writeln(_generateManualModel(model, config));
    }

    return buffer.toString();
  }

  String _generateManualModel(ModelDefinition model, FeatureConfig config) {
    final buffer = StringBuffer();
    final entityImportPath =
        '../../domain/entities/${model.name.toSnakeCase}_entity.dart';

    buffer.writeln("import '$entityImportPath';");
    buffer.writeln('');
    buffer.writeln('/// ${model.name}Model — data transfer object with JSON serialization.');
    buffer.writeln('///');
    buffer.writeln('/// Maps to/from JSON for API communication and converts');
    buffer.writeln('/// to the domain entity [${model.name}].');
    buffer.writeln('class ${model.name}Model {');

    // Fields
    for (final field in model.fields) {
      buffer.writeln('  final ${field.type} ${field.name};');
    }
    buffer.writeln('');

    // Constructor
    buffer.writeln('  const ${model.name}Model({');
    for (final field in model.fields) {
      if (field.isRequired && !field.isNullable) {
        if (field.defaultValue != null) {
          buffer.writeln('    this.${field.name} = ${field.defaultValue},');
        } else {
          buffer.writeln('    required this.${field.name},');
        }
      } else {
        buffer.writeln('    this.${field.name},');
      }
    }
    buffer.writeln('  });');

    // fromJson factory
    buffer.writeln('');
    buffer.writeln(
        '  /// Creates a [${model.name}Model] from a JSON map.');
    buffer.writeln(
        '  factory ${model.name}Model.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return ${model.name}Model(');
    for (final field in model.fields) {
      final jsonKey = field.jsonKey ?? field.name.toSnakeCase;
      buffer.writeln(
          "      ${field.name}: ${_fromJsonExpression(field, jsonKey)},");
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    // toJson method
    buffer.writeln('');
    buffer.writeln('  /// Converts this model to a JSON map.');
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.writeln('    return {');
    for (final field in model.fields) {
      final jsonKey = field.jsonKey ?? field.name.toSnakeCase;
      buffer.writeln("      '$jsonKey': ${field.name},");
    }
    buffer.writeln('    };');
    buffer.writeln('  }');

    // toEntity
    buffer.writeln('');
    buffer.writeln('  /// Converts this model to a domain entity.');
    buffer.writeln('  ${model.name} toEntity() {');
    buffer.writeln('    return ${model.name}(');
    for (final field in model.fields) {
      buffer.writeln('      ${field.name}: ${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    // fromEntity
    buffer.writeln('');
    buffer.writeln('  /// Creates a model from a domain entity.');
    buffer.writeln(
        '  factory ${model.name}Model.fromEntity(${model.name} entity) {');
    buffer.writeln('    return ${model.name}Model(');
    for (final field in model.fields) {
      buffer.writeln('      ${field.name}: entity.${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateJsonSerializableModel(
      ModelDefinition model, String snakeName, FeatureConfig config) {
    final buffer = StringBuffer();
    final entityImportPath =
        '../../domain/entities/${model.name.toSnakeCase}_entity.dart';

    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    buffer.writeln("import '$entityImportPath';");
    buffer.writeln('');
    buffer.writeln("part '${snakeName}_model.g.dart';");
    buffer.writeln('');
    buffer.writeln('@JsonSerializable()');
    buffer.writeln('class ${model.name}Model {');

    // Fields with JsonKey annotations
    for (final field in model.fields) {
      final jsonKey = field.jsonKey ?? field.name.toSnakeCase;
      if (jsonKey != field.name) {
        buffer.writeln("  @JsonKey(name: '$jsonKey')");
      }
      buffer.writeln('  final ${field.type} ${field.name};');
    }
    buffer.writeln('');

    // Constructor
    buffer.writeln('  const ${model.name}Model({');
    for (final field in model.fields) {
      if (field.isRequired && !field.isNullable) {
        if (field.defaultValue != null) {
          buffer.writeln('    this.${field.name} = ${field.defaultValue},');
        } else {
          buffer.writeln('    required this.${field.name},');
        }
      } else {
        buffer.writeln('    this.${field.name},');
      }
    }
    buffer.writeln('  });');

    // fromJson / toJson
    buffer.writeln('');
    buffer.writeln(
        '  factory ${model.name}Model.fromJson(Map<String, dynamic> json) =>');
    buffer.writeln('      _\$${model.name}ModelFromJson(json);');
    buffer.writeln('');
    buffer.writeln(
        '  Map<String, dynamic> toJson() => _\$${model.name}ModelToJson(this);');

    // toEntity
    buffer.writeln('');
    buffer.writeln('  ${model.name} toEntity() {');
    buffer.writeln('    return ${model.name}(');
    for (final field in model.fields) {
      buffer.writeln('      ${field.name}: ${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    // fromEntity
    buffer.writeln('');
    buffer.writeln(
        '  factory ${model.name}Model.fromEntity(${model.name} entity) {');
    buffer.writeln('    return ${model.name}Model(');
    for (final field in model.fields) {
      buffer.writeln('      ${field.name}: entity.${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateFreezedModel(ModelDefinition model, String snakeName) {
    final buffer = StringBuffer();
    final entityImportPath =
        '../../domain/entities/${model.name.toSnakeCase}_entity.dart';

    buffer.writeln("import 'package:freezed_annotation/freezed_annotation.dart';");
    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    buffer.writeln("import '$entityImportPath';");
    buffer.writeln('');
    buffer.writeln("part '${snakeName}_model.freezed.dart';");
    buffer.writeln("part '${snakeName}_model.g.dart';");
    buffer.writeln('');
    buffer.writeln('@freezed');
    buffer.writeln('class ${model.name}Model with _\$${model.name}Model {');
    buffer.writeln('  const ${model.name}Model._();');
    buffer.writeln('');
    buffer.writeln('  const factory ${model.name}Model({');
    for (final field in model.fields) {
      final jsonKey = field.jsonKey ?? field.name.toSnakeCase;
      if (jsonKey != field.name) {
        buffer.writeln("    @JsonKey(name: '$jsonKey')");
      }
      if (field.isRequired && !field.isNullable) {
        if (field.defaultValue != null) {
          buffer.writeln(
              '    @Default(${field.defaultValue}) ${field.type} ${field.name},');
        } else {
          buffer.writeln('    required ${field.type} ${field.name},');
        }
      } else {
        buffer.writeln('    ${field.type} ${field.name},');
      }
    }
    buffer.writeln('  }) = _${model.name}Model;');
    buffer.writeln('');
    buffer.writeln(
        '  factory ${model.name}Model.fromJson(Map<String, dynamic> json) =>');
    buffer.writeln('      _\$${model.name}ModelFromJson(json);');
    buffer.writeln('');
    buffer.writeln('  ${model.name} toEntity() => ${model.name}(');
    for (final field in model.fields) {
      buffer.writeln('    ${field.name}: ${field.name},');
    }
    buffer.writeln('  );');
    buffer.writeln('');
    buffer.writeln(
        '  static ${model.name}Model fromEntity(${model.name} entity) =>');
    buffer.writeln('      ${model.name}Model(');
    for (final field in model.fields) {
      buffer.writeln('        ${field.name}: entity.${field.name},');
    }
    buffer.writeln('      );');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _fromJsonExpression(FieldDefinition field, String jsonKey) {
    final accessor = "json['$jsonKey']";
    if (field.isNullable) {
      return '$accessor as ${field.type}';
    }
    if (field.type == 'int') return '$accessor as int';
    if (field.type == 'double') return '($accessor as num).toDouble()';
    if (field.type == 'bool') return '$accessor as bool';
    if (field.type == 'String') return '$accessor as String';
    if (field.type == 'DateTime') return 'DateTime.parse($accessor as String)';
    if (field.isList) return '($accessor as List).cast()';
    return '$accessor as ${field.type}';
  }
}
