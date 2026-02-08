import '../models/feature_config.dart';
import '../models/model_definition.dart';
import '../utils/string_utils.dart';

/// Generates domain layer entity classes.
class EntityTemplate {
  const EntityTemplate();

  /// Generate entity class code for a model.
  String generate(ModelDefinition model, FeatureConfig config) {
    final buffer = StringBuffer();

    buffer.write(StringUtils.fileHeader(
        'Entity: ${model.name} for feature "${config.name}"'));

    if (config.useFreezed) {
      buffer.writeln(_generateFreezedEntity(model));
    } else {
      buffer.writeln(_generateStandardEntity(model));
    }

    return buffer.toString();
  }

  String _generateStandardEntity(ModelDefinition model) {
    final buffer = StringBuffer();

    buffer.writeln('/// ${model.name} entity — pure domain object.');
    buffer.writeln('///');
    buffer.writeln('/// This class has no dependencies on external packages');
    buffer.writeln('/// (no JSON, no framework imports). It represents the');
    buffer.writeln('/// core business data for ${model.name}.');
    buffer.writeln('class ${model.name} {');

    // Fields
    for (final field in model.fields) {
      buffer.writeln('  final ${field.type} ${field.name};');
    }
    buffer.writeln('');

    // Constructor
    buffer.writeln('  const ${model.name}({');
    for (final field in model.fields) {
      if (field.isRequired && !field.isNullable) {
        if (field.defaultValue != null) {
          buffer.writeln('    this.${field.name} = ${field.defaultValue},');
        } else {
          buffer.writeln('    required this.${field.name},');
        }
      } else {
        if (field.defaultValue != null) {
          buffer.writeln('    this.${field.name} = ${field.defaultValue},');
        } else {
          buffer.writeln('    this.${field.name},');
        }
      }
    }
    buffer.writeln('  });');

    // copyWith
    if (model.generateCopyWith) {
      buffer.writeln('');
      buffer.writeln('  /// Creates a copy of this ${model.name} with the given fields replaced.');
      buffer.writeln('  ${model.name} copyWith({');
      for (final field in model.fields) {
        final nullableType =
            field.isNullable ? field.type : '${field.type}?';
        buffer.writeln('    $nullableType ${field.name},');
      }
      buffer.writeln('  }) {');
      buffer.writeln('    return ${model.name}(');
      for (final field in model.fields) {
        buffer.writeln(
            '      ${field.name}: ${field.name} ?? this.${field.name},');
      }
      buffer.writeln('    );');
      buffer.writeln('  }');
    }

    // Equality
    if (model.generateEquality) {
      buffer.writeln('');
      buffer.writeln('  @override');
      buffer.writeln('  bool operator ==(Object other) {');
      buffer.writeln(
          '    if (identical(this, other)) return true;');
      buffer.writeln('    return other is ${model.name}');
      for (var i = 0; i < model.fields.length; i++) {
        final field = model.fields[i];
        final suffix = i == model.fields.length - 1 ? ';' : '';
        buffer.writeln(
            '        && other.${field.name} == ${field.name}$suffix');
      }
      buffer.writeln('  }');
      buffer.writeln('');
      buffer.writeln('  @override');
      buffer.writeln(
          '  int get hashCode => Object.hash(${model.fields.map((f) => f.name).join(', ')});');
    }

    // toString
    if (model.generateToString) {
      buffer.writeln('');
      buffer.writeln('  @override');
      final fieldStrings =
          model.fields.map((f) => '${f.name}: \$${f.name}').join(', ');
      buffer.writeln(
          "  String toString() => '${model.name}($fieldStrings)';");
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateFreezedEntity(ModelDefinition model) {
    final buffer = StringBuffer();
    final snakeName = model.name.toSnakeCase;

    buffer.writeln("import 'package:freezed_annotation/freezed_annotation.dart';");
    buffer.writeln('');
    buffer.writeln("part '${snakeName}_entity.freezed.dart';");
    buffer.writeln('');
    buffer.writeln('@freezed');
    buffer.writeln(
        'class ${model.name} with _\$${model.name} {');
    buffer.writeln('  const factory ${model.name}({');
    for (final field in model.fields) {
      if (field.isRequired && !field.isNullable) {
        if (field.defaultValue != null) {
          buffer.writeln(
              '    @Default(${field.defaultValue}) ${field.type} ${field.name},');
        } else {
          buffer.writeln('    required ${field.type} ${field.name},');
        }
      } else {
        if (field.defaultValue != null) {
          buffer.writeln(
              '    @Default(${field.defaultValue}) ${field.type} ${field.name},');
        } else {
          buffer.writeln('    ${field.type} ${field.name},');
        }
      }
    }
    buffer.writeln('  }) = _${model.name};');
    buffer.writeln('}');

    return buffer.toString();
  }
}
