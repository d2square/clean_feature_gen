import '../models/feature_config.dart';
import '../models/usecase_definition.dart';
import '../utils/string_utils.dart';

/// Generates domain layer use case classes.
class UsecaseTemplate {
  const UsecaseTemplate();

  /// Generate a use case class.
  String generate(UsecaseDefinition usecase, FeatureConfig config) {
    final buffer = StringBuffer();
    final className = usecase.name.toPascalCase;
    final snakeName = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'UseCase: $className for feature "${config.name}"'));

    buffer.writeln(
        "import '../repositories/${snakeName}_repository.dart';");

    // Import entity types used in return type
    for (final model in config.models) {
      buffer.writeln(
          "import '../entities/${model.name.toSnakeCase}_entity.dart';");
    }
    if (usecase.useEither) {
      buffer.writeln("import '../entities/failure.dart';");
    }
    buffer.writeln('');

    // Generate Params class if the use case has parameters
    if (usecase.hasParams) {
      buffer.writeln('/// Parameters for [$className] use case.');
      buffer.writeln('class ${className}Params {');
      for (final param in usecase.params) {
        buffer.writeln('  final ${param.type} ${param.name};');
      }
      buffer.writeln('');
      buffer.writeln('  const ${className}Params({');
      for (final param in usecase.params) {
        buffer.writeln('    required this.${param.name},');
      }
      buffer.writeln('  });');
      buffer.writeln('}');
      buffer.writeln('');
    }

    // Use case class
    buffer.writeln('/// $className use case.');
    buffer.writeln('///');
    buffer.writeln(
        '/// Encapsulates a single business operation for ${config.name.toPascalCase}.');
    buffer.writeln(
        '/// Depends only on the repository interface (dependency inversion).');
    buffer.writeln('class $className {');
    buffer.writeln(
        '  final ${config.name.toPascalCase}Repository _repository;');
    buffer.writeln('');
    buffer.writeln(
        '  const $className({required ${config.name.toPascalCase}Repository repository})');
    buffer.writeln('      : _repository = repository;');
    buffer.writeln('');

    // Call method
    final returnType = _fullReturnType(usecase);
    final paramType =
        usecase.hasParams ? '${className}Params params' : '';

    buffer.writeln('  /// Execute this use case.');
    buffer.writeln('  $returnType call($paramType) {');

    final args = usecase.hasParams
        ? usecase.params.map((p) => 'params.${p.name}').join(', ')
        : '';

    buffer.writeln(
        '    return _repository.${usecase.name.toCamelCase}($args);');
    buffer.writeln('  }');

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate the shared Failure class.
  String generateFailure() {
    final buffer = StringBuffer();

    buffer.write(StringUtils.fileHeader('Failure class for error handling'));

    buffer.writeln('/// Represents a failure in a domain operation.');
    buffer.writeln('///');
    buffer.writeln('/// Used as the error type in result tuples returned');
    buffer.writeln('/// by repositories and use cases.');
    buffer.writeln('class Failure {');
    buffer.writeln('  /// Human-readable error message.');
    buffer.writeln('  final String message;');
    buffer.writeln('');
    buffer.writeln('  /// Optional error code for programmatic handling.');
    buffer.writeln('  final String? code;');
    buffer.writeln('');
    buffer.writeln('  /// Optional stack trace for debugging.');
    buffer.writeln('  final StackTrace? stackTrace;');
    buffer.writeln('');
    buffer.writeln('  const Failure({');
    buffer.writeln('    required this.message,');
    buffer.writeln('    this.code,');
    buffer.writeln('    this.stackTrace,');
    buffer.writeln('  });');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln(
        "  String toString() => 'Failure(message: \$message, code: \$code)';");
    buffer.writeln('}');
    buffer.writeln('');

    // Common failure subtypes
    buffer.writeln('/// Network-related failure.');
    buffer.writeln('class NetworkFailure extends Failure {');
    buffer.writeln('  const NetworkFailure({super.message = "Network error occurred", super.code, super.stackTrace});');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('/// Server-returned error.');
    buffer.writeln('class ServerFailure extends Failure {');
    buffer.writeln('  final int? statusCode;');
    buffer.writeln('  const ServerFailure({super.message = "Server error occurred", this.statusCode, super.code, super.stackTrace});');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('/// Cache or local storage failure.');
    buffer.writeln('class CacheFailure extends Failure {');
    buffer.writeln('  const CacheFailure({super.message = "Cache error occurred", super.code, super.stackTrace});');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('/// Authentication failure.');
    buffer.writeln('class AuthFailure extends Failure {');
    buffer.writeln('  const AuthFailure({super.message = "Authentication failed", super.code, super.stackTrace});');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _fullReturnType(UsecaseDefinition usecase) {
    if (usecase.useEither) {
      if (usecase.isVoid) {
        return 'Future<({Failure? failure, void data})>';
      }
      return 'Future<({Failure? failure, ${usecase.returnType}? data})>';
    }
    return usecase.isStream
        ? 'Stream<${usecase.returnType}>'
        : 'Future<${usecase.returnType}>';
  }
}
