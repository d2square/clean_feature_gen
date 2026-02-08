import '../models/feature_config.dart';
import '../models/usecase_definition.dart';
import '../utils/string_utils.dart';

/// Generates the repository interface (domain layer) and implementation (data layer).
class RepositoryTemplate {
  const RepositoryTemplate();

  /// Generate repository interface (domain layer).
  String generateInterface(FeatureConfig config) {
    final buffer = StringBuffer();
    final className = '${config.name.toPascalCase}Repository';

    buffer.write(StringUtils.fileHeader(
        'Repository Interface for feature "${config.name}"'));

    // Imports for return types
    for (final model in config.models) {
      buffer.writeln(
          "import '../entities/${model.name.toSnakeCase}_entity.dart';");
    }
    if (config.usecases.any((u) => u.useEither)) {
      buffer.writeln("import '../entities/failure.dart';");
    }
    buffer.writeln('');

    buffer.writeln('/// Repository contract for ${config.name.toPascalCase} feature.');
    buffer.writeln('///');
    buffer.writeln('/// Defines the data operations available for this feature.');
    buffer.writeln('/// The implementation lives in the data layer.');
    buffer.writeln('abstract class $className {');

    for (final usecase in config.usecases) {
      buffer.writeln('');
      buffer.writeln('  /// ${_usecaseDescription(usecase)}');
      buffer.writeln('  ${_methodSignature(usecase)};');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate repository implementation (data layer).
  String generateImplementation(FeatureConfig config) {
    final buffer = StringBuffer();
    final interfaceName = '${config.name.toPascalCase}Repository';
    final implName = '${config.name.toPascalCase}RepositoryImpl';
    final snakeName = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Repository Implementation for feature "${config.name}"'));

    buffer.writeln(
        "import '../../domain/repositories/${snakeName}_repository.dart';");

    for (final model in config.models) {
      buffer.writeln(
          "import '../../domain/entities/${model.name.toSnakeCase}_entity.dart';");
      buffer.writeln(
          "import '../models/${model.name.toSnakeCase}_model.dart';");
    }

    if (config.usecases.any((u) => u.useEither)) {
      buffer.writeln("import '../../domain/entities/failure.dart';");
    }

    if (config.hasApi) {
      buffer.writeln(
          "import '../datasources/${snakeName}_remote_data_source.dart';");
    }
    if (config.hasLocalDataSource) {
      buffer.writeln(
          "import '../datasources/${snakeName}_local_data_source.dart';");
    }
    buffer.writeln('');

    buffer.writeln('/// Implementation of [$interfaceName].');
    buffer.writeln('///');
    buffer.writeln('/// Coordinates between remote and local data sources,');
    buffer.writeln('/// handles caching strategy, and maps DTOs to entities.');
    buffer.writeln('class $implName implements $interfaceName {');

    // Data source fields
    if (config.hasApi) {
      buffer.writeln(
          '  final ${config.name.toPascalCase}RemoteDataSource _remoteDataSource;');
    }
    if (config.hasLocalDataSource) {
      buffer.writeln(
          '  final ${config.name.toPascalCase}LocalDataSource _localDataSource;');
    }
    buffer.writeln('');

    // Constructor
    buffer.writeln('  const $implName({');
    if (config.hasApi) {
      buffer.writeln(
          '    required ${config.name.toPascalCase}RemoteDataSource remoteDataSource,');
    }
    if (config.hasLocalDataSource) {
      buffer.writeln(
          '    required ${config.name.toPascalCase}LocalDataSource localDataSource,');
    }
    buffer.writeln('  })');
    final assignments = <String>[];
    if (config.hasApi) assignments.add('_remoteDataSource = remoteDataSource');
    if (config.hasLocalDataSource) {
      assignments.add('_localDataSource = localDataSource');
    }
    if (assignments.isNotEmpty) {
      buffer.writeln('      : ${assignments.join(',\n        ')};');
    } else {
      buffer.writeln('      ;');
    }

    // Method implementations
    for (final usecase in config.usecases) {
      buffer.writeln('');
      buffer.writeln('  @override');
      buffer.writeln('  ${_methodSignature(usecase)} async {');
      if (usecase.useEither) {
        buffer.writeln('    try {');
        buffer.writeln('      ${_methodBody(usecase, config)}');
        buffer.writeln('    } catch (e) {');
        buffer.writeln(
            "      return (failure: Failure(message: e.toString()), data: null);");
        buffer.writeln('    }');
      } else {
        buffer.writeln('    ${_methodBody(usecase, config)}');
      }
      buffer.writeln('  }');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _methodSignature(UsecaseDefinition usecase) {
    final params = usecase.params
        .map((p) => '${p.type} ${p.name}')
        .join(', ');

    String returnType;
    if (usecase.useEither) {
      if (usecase.isVoid) {
        returnType =
            'Future<({Failure? failure, void data})>';
      } else {
        returnType =
            'Future<({Failure? failure, ${usecase.returnType}? data})>';
      }
    } else {
      returnType = usecase.isStream
          ? 'Stream<${usecase.returnType}>'
          : 'Future<${usecase.returnType}>';
    }

    return '$returnType ${usecase.name.toCamelCase}($params)';
  }

  String _methodBody(UsecaseDefinition usecase, FeatureConfig config) {
    final buffer = StringBuffer();

    if (config.hasApi) {
      final methodCall =
          '_remoteDataSource.${usecase.name.toCamelCase}(${usecase.params.map((p) => p.name).join(', ')})';

      if (usecase.isVoid) {
        buffer.writeln('await $methodCall;');
        if (usecase.useEither) {
          buffer.writeln(
              '      return (failure: null, data: null);');
        }
      } else {
        buffer.writeln('final result = await $methodCall;');
        if (usecase.useEither) {
          buffer.writeln(
              '      return (failure: null, data: result.toEntity());');
        } else {
          buffer.writeln('      return result.toEntity();');
        }
      }
    } else {
      buffer.writeln('// TODO: Implement ${usecase.name.toCamelCase}');
      buffer.writeln('      throw UnimplementedError();');
    }

    return buffer.toString();
  }

  String _usecaseDescription(UsecaseDefinition usecase) {
    final name = usecase.name.toPascalCase;
    if (usecase.isVoid) return '$name operation.';
    return '$name — returns ${usecase.returnType}.';
  }
}
