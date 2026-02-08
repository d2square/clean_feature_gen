import '../models/feature_config.dart';
import '../utils/string_utils.dart';

/// Generates remote and local data source classes.
class DataSourceTemplate {
  const DataSourceTemplate();

  /// Generate remote data source (API calls).
  String generateRemote(FeatureConfig config) {
    final buffer = StringBuffer();
    final className = '${config.name.toPascalCase}RemoteDataSource';
    final snakeName = config.name.toSnakeCase;
    final apiBase = config.apiBase ?? '/api/v1/$snakeName';

    buffer.write(StringUtils.fileHeader(
        'Remote Data Source for feature "${config.name}"'));

    for (final model in config.models) {
      buffer.writeln(
          "import '../models/${model.name.toSnakeCase}_model.dart';");
    }
    buffer.writeln('');

    // Abstract class
    buffer.writeln('/// Remote data source contract for ${config.name.toPascalCase}.');
    buffer.writeln('///');
    buffer.writeln('/// Handles all network API calls for this feature.');
    buffer.writeln('abstract class $className {');
    for (final usecase in config.usecases) {
      final params = usecase.params
          .map((p) => '${p.type} ${p.name}')
          .join(', ');
      final returnModel = usecase.isVoid
          ? 'Future<void>'
          : 'Future<${usecase.returnType}Model>';
      buffer.writeln('  $returnModel ${usecase.name.toCamelCase}($params);');
    }
    buffer.writeln('}');

    buffer.writeln('');

    // Implementation
    buffer.writeln('/// Implementation of [$className] using Dio/HTTP client.');
    buffer.writeln('///');
    buffer.writeln('/// Base endpoint: $apiBase');
    buffer.writeln('class ${className}Impl implements $className {');
    buffer.writeln('  // TODO: Inject your HTTP client (Dio, http, etc.)');
    buffer.writeln('  // final Dio _dio;');
    buffer.writeln('');
    buffer.writeln('  const ${className}Impl(');
    buffer.writeln('    // {required Dio dio}');
    buffer.writeln('  );');
    buffer.writeln('  // : _dio = dio;');
    buffer.writeln('');

    for (final usecase in config.usecases) {
      final params = usecase.params
          .map((p) => '${p.type} ${p.name}')
          .join(', ');
      final returnModel = usecase.isVoid
          ? 'Future<void>'
          : 'Future<${usecase.returnType}Model>';

      buffer.writeln('  @override');
      buffer.writeln('  $returnModel ${usecase.name.toCamelCase}($params) async {');
      buffer.writeln(
          '    // TODO: Implement API call to $apiBase');
      buffer.writeln('    //');
      buffer.writeln('    // Example with Dio:');

      if (usecase.name.toLowerCase().startsWith('get') ||
          usecase.name.toLowerCase().startsWith('fetch') ||
          usecase.name.toLowerCase().startsWith('load')) {
        buffer.writeln("    // final response = await _dio.get('$apiBase');");
      } else if (usecase.name.toLowerCase().startsWith('create') ||
          usecase.name.toLowerCase().startsWith('add')) {
        buffer.writeln(
            "    // final response = await _dio.post('$apiBase', data: {});");
      } else if (usecase.name.toLowerCase().startsWith('update') ||
          usecase.name.toLowerCase().startsWith('edit')) {
        buffer.writeln(
            "    // final response = await _dio.put('$apiBase', data: {});");
      } else if (usecase.name.toLowerCase().startsWith('delete') ||
          usecase.name.toLowerCase().startsWith('remove')) {
        buffer.writeln(
            "    // final response = await _dio.delete('$apiBase');");
      } else {
        buffer.writeln(
            "    // final response = await _dio.post('$apiBase', data: {});");
      }

      if (!usecase.isVoid) {
        buffer.writeln(
            '    // return ${usecase.returnType}Model.fromJson(response.data);');
      }
      buffer.writeln('    throw UnimplementedError();');
      buffer.writeln('  }');
      buffer.writeln('');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate local data source (caching/offline).
  String generateLocal(FeatureConfig config) {
    final buffer = StringBuffer();
    final className = '${config.name.toPascalCase}LocalDataSource';

    buffer.write(StringUtils.fileHeader(
        'Local Data Source for feature "${config.name}"'));

    for (final model in config.models) {
      buffer.writeln(
          "import '../models/${model.name.toSnakeCase}_model.dart';");
    }
    buffer.writeln('');

    // Abstract class
    buffer.writeln('/// Local data source contract for ${config.name.toPascalCase}.');
    buffer.writeln('///');
    buffer.writeln('/// Handles local persistence (cache, offline data, etc.).');
    buffer.writeln('abstract class $className {');
    if (config.models.isNotEmpty) {
      final primaryModel = config.models.first;
      buffer.writeln(
          '  Future<${primaryModel.name}Model?> getCached${primaryModel.name}();');
      buffer.writeln(
          '  Future<void> cache${primaryModel.name}(${primaryModel.name}Model model);');
      buffer.writeln('  Future<void> clearCache();');
    }
    buffer.writeln('}');

    buffer.writeln('');

    // Implementation
    buffer.writeln('/// Implementation of [$className].');
    buffer.writeln('///');
    buffer.writeln('/// Uses SharedPreferences/Hive for local storage.');
    buffer.writeln('class ${className}Impl implements $className {');
    buffer.writeln(
        '  // TODO: Inject your local storage (SharedPreferences, Hive, etc.)');
    buffer.writeln('');

    buffer.writeln('  const ${className}Impl();');
    buffer.writeln('');

    if (config.models.isNotEmpty) {
      final primaryModel = config.models.first;
      buffer.writeln('  @override');
      buffer.writeln(
          '  Future<${primaryModel.name}Model?> getCached${primaryModel.name}() async {');
      buffer.writeln(
          '    // TODO: Retrieve from local storage');
      buffer.writeln('    return null;');
      buffer.writeln('  }');
      buffer.writeln('');
      buffer.writeln('  @override');
      buffer.writeln(
          '  Future<void> cache${primaryModel.name}(${primaryModel.name}Model model) async {');
      buffer.writeln(
          '    // TODO: Save to local storage');
      buffer.writeln('  }');
      buffer.writeln('');
      buffer.writeln('  @override');
      buffer.writeln('  Future<void> clearCache() async {');
      buffer.writeln('    // TODO: Clear local storage');
      buffer.writeln('  }');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
