import '../models/feature_config.dart';
import '../utils/string_utils.dart';

/// Generates dependency injection setup.
class DiTemplate {
  const DiTemplate();

  String generate(FeatureConfig config) {
    final buffer = StringBuffer();
    final pascal = config.name.toPascalCase;
    final snake = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Dependency Injection for feature "${config.name}"'));

    buffer.writeln("// Import your DI framework (get_it, injectable, etc.)");
    buffer.writeln("// import 'package:get_it/get_it.dart';");
    buffer.writeln('');

    // Imports
    if (config.hasApi) {
      buffer.writeln(
          "import '../data/datasources/${snake}_remote_data_source.dart';");
    }
    if (config.hasLocalDataSource) {
      buffer.writeln(
          "import '../data/datasources/${snake}_local_data_source.dart';");
    }
    buffer.writeln(
        "import '../data/repositories/${snake}_repository_impl.dart';");
    buffer.writeln(
        "import '../domain/repositories/${snake}_repository.dart';");
    for (final usecase in config.usecases) {
      buffer.writeln(
          "import '../domain/usecases/${usecase.name.toSnakeCase}_usecase.dart';");
    }
    if (config.stateManagement == StateManagement.bloc) {
      buffer.writeln(
          "import '../presentation/bloc/${snake}_bloc.dart';");
    } else {
      buffer.writeln(
          "import '../presentation/cubit/${snake}_cubit.dart';");
    }
    buffer.writeln('');

    buffer.writeln('/// Register all dependencies for the ${pascal} feature.');
    buffer.writeln('///');
    buffer.writeln('/// Call this function from your main DI setup.');
    buffer.writeln('///');
    buffer.writeln('/// Example with get_it:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// final sl = GetIt.instance;');
    buffer.writeln('/// register${pascal}Dependencies(sl);');
    buffer.writeln('/// ```');
    buffer.writeln(
        'void register${pascal}Dependencies(/* GetIt sl */) {');
    buffer.writeln('  // ═══════════════════════════════════════');
    buffer.writeln('  // Data Sources');
    buffer.writeln('  // ═══════════════════════════════════════');

    if (config.hasApi) {
      buffer.writeln('');
      buffer.writeln('  // sl.registerLazySingleton<${pascal}RemoteDataSource>(');
      buffer.writeln('  //   () => ${pascal}RemoteDataSourceImpl(');
      buffer.writeln('  //     // dio: sl(),');
      buffer.writeln('  //   ),');
      buffer.writeln('  // );');
    }
    if (config.hasLocalDataSource) {
      buffer.writeln('');
      buffer.writeln('  // sl.registerLazySingleton<${pascal}LocalDataSource>(');
      buffer.writeln('  //   () => const ${pascal}LocalDataSourceImpl(),');
      buffer.writeln('  // );');
    }

    buffer.writeln('');
    buffer.writeln('  // ═══════════════════════════════════════');
    buffer.writeln('  // Repository');
    buffer.writeln('  // ═══════════════════════════════════════');
    buffer.writeln('');
    buffer.writeln('  // sl.registerLazySingleton<${pascal}Repository>(');
    buffer.writeln('  //   () => ${pascal}RepositoryImpl(');
    if (config.hasApi) {
      buffer.writeln('  //     remoteDataSource: sl(),');
    }
    if (config.hasLocalDataSource) {
      buffer.writeln('  //     localDataSource: sl(),');
    }
    buffer.writeln('  //   ),');
    buffer.writeln('  // );');

    buffer.writeln('');
    buffer.writeln('  // ═══════════════════════════════════════');
    buffer.writeln('  // Use Cases');
    buffer.writeln('  // ═══════════════════════════════════════');
    for (final usecase in config.usecases) {
      buffer.writeln('');
      buffer.writeln(
          '  // sl.registerLazySingleton(() => ${usecase.name.toPascalCase}(repository: sl()));');
    }

    buffer.writeln('');
    buffer.writeln('  // ═══════════════════════════════════════');
    buffer.writeln('  // BLoC / Cubit');
    buffer.writeln('  // ═══════════════════════════════════════');
    buffer.writeln('');

    if (config.stateManagement == StateManagement.bloc) {
      buffer.writeln('  // sl.registerFactory(() => ${pascal}Bloc(');
      for (final usecase in config.usecases) {
        buffer.writeln(
            '  //   ${usecase.name.toCamelCase}: sl(),');
      }
      buffer.writeln('  // ));');
    } else {
      buffer.writeln('  // sl.registerFactory(() => ${pascal}Cubit(');
      for (final usecase in config.usecases) {
        buffer.writeln(
            '  //   ${usecase.name.toCamelCase}: sl(),');
      }
      buffer.writeln('  // ));');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}

/// Generates route configuration.
class RouteTemplate {
  const RouteTemplate();

  String generate(FeatureConfig config) {
    final buffer = StringBuffer();
    final snake = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Routes for feature "${config.name}"'));

    buffer.writeln("import 'package:flutter/material.dart';");
    for (final screen in config.screens) {
      buffer.writeln(
          "import '../presentation/screens/${screen.name.toSnakeCase}.dart';");
    }
    buffer.writeln('');

    buffer.writeln('/// Route names for ${config.name.toPascalCase} feature.');
    buffer.writeln('class ${config.name.toPascalCase}Routes {');
    buffer.writeln('  ${config.name.toPascalCase}Routes._();');
    buffer.writeln('');
    for (final screen in config.screens) {
      buffer.writeln(
          "  static const ${screen.name.toCamelCase} = '/${snake}/${screen.name.toSnakeCase}';");
    }
    buffer.writeln('}');
    buffer.writeln('');

    buffer.writeln('/// Generate routes for ${config.name.toPascalCase} feature.');
    buffer.writeln('///');
    buffer.writeln('/// Usage with GoRouter:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// ...${config.name.toCamelCase}Routes(),');
    buffer.writeln('/// ```');
    buffer.writeln('///');
    buffer.writeln('/// Usage with Navigator:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// routes: {');
    buffer.writeln('///   ...${config.name.toCamelCase}RouteMap(),');
    buffer.writeln('/// }');
    buffer.writeln('/// ```');
    buffer.writeln(
        'Map<String, WidgetBuilder> ${config.name.toCamelCase}RouteMap() {');
    buffer.writeln('  return {');
    for (final screen in config.screens) {
      buffer.writeln(
          "    ${config.name.toPascalCase}Routes.${screen.name.toCamelCase}: (_) => const ${screen.name}(),");
    }
    buffer.writeln('  };');
    buffer.writeln('}');

    return buffer.toString();
  }
}
