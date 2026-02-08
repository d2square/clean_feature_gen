import '../models/feature_config.dart';
import '../utils/string_utils.dart';

/// Generates unit test stubs for BLoC, use cases, and repository.
class TestTemplate {
  const TestTemplate();

  /// Generate BLoC test.
  String generateBlocTest(FeatureConfig config) {
    final buffer = StringBuffer();
    final pascal = config.name.toPascalCase;
    final snake = config.name.toSnakeCase;
    final blocName = '${pascal}Bloc';

    buffer.write(StringUtils.fileHeader(
        'BLoC Tests for feature "${config.name}"'));

    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:bloc_test/bloc_test.dart';");
    buffer.writeln("import 'package:mocktail/mocktail.dart';");
    buffer.writeln('');

    // Import the actual files
    buffer.writeln('// TODO: Update imports with your actual package name');
    buffer.writeln('// import "package:your_app/features/$snake/presentation/bloc/${snake}_bloc.dart";');
    buffer.writeln('// import "package:your_app/features/$snake/presentation/bloc/${snake}_event.dart";');
    buffer.writeln('// import "package:your_app/features/$snake/presentation/bloc/${snake}_state.dart";');

    for (final usecase in config.usecases) {
      buffer.writeln(
          '// import "package:your_app/features/$snake/domain/usecases/${usecase.name.toSnakeCase}_usecase.dart";');
    }
    buffer.writeln('');

    // Mock classes
    for (final usecase in config.usecases) {
      buffer.writeln(
          '// class Mock${usecase.name.toPascalCase} extends Mock implements ${usecase.name.toPascalCase} {}');
    }
    buffer.writeln('');

    buffer.writeln('void main() {');

    // Declare variables
    buffer.writeln('  // late $blocName bloc;');
    for (final usecase in config.usecases) {
      buffer.writeln(
          '  // late Mock${usecase.name.toPascalCase} mock${usecase.name.toPascalCase};');
    }
    buffer.writeln('');

    // setUp
    buffer.writeln('  setUp(() {');
    for (final usecase in config.usecases) {
      buffer.writeln(
          '    // mock${usecase.name.toPascalCase} = Mock${usecase.name.toPascalCase}();');
    }
    buffer.writeln('    // bloc = $blocName(');
    for (final usecase in config.usecases) {
      buffer.writeln(
          '    //   ${usecase.name.toCamelCase}: mock${usecase.name.toPascalCase},');
    }
    buffer.writeln('    // );');
    buffer.writeln('  });');
    buffer.writeln('');

    // tearDown
    buffer.writeln('  tearDown(() {');
    buffer.writeln('    // bloc.close();');
    buffer.writeln('  });');
    buffer.writeln('');

    // Initial state test
    buffer.writeln("  group('$blocName', () {");
    buffer.writeln("    test('initial state is correct', () {");
    buffer.writeln(
        '      // expect(bloc.state.status, ${blocName}Status.initial);');
    buffer.writeln('    });');

    // Tests for each use case
    for (final usecase in config.usecases) {
      buffer.writeln('');
      buffer.writeln(
          "    group('${usecase.name.toPascalCase}', () {");

      // Success test
      buffer.writeln(
          "      blocTest<$blocName, ${blocName}State>(");
      buffer.writeln(
          "        'emits [loading, loaded] when ${usecase.name.toCamelCase} succeeds',");
      buffer.writeln('        build: () {');
      buffer.writeln(
          '          // when(() => mock${usecase.name.toPascalCase}.call(');
      if (usecase.hasParams) {
        buffer.writeln(
            '          //   any(),');
      }
      buffer.writeln(
          '          // )).thenAnswer((_) async => (failure: null, data: null));');
      buffer.writeln('          // return bloc;');
      buffer.writeln('          throw UnimplementedError();');
      buffer.writeln('        },');
      buffer.writeln(
          '        act: (bloc) => bloc.add(const ${usecase.name.toPascalCase}Event(');
      if (usecase.hasParams) {
        for (final param in usecase.params) {
          buffer.writeln(
              '          // ${param.name}: /* test value */,');
        }
      }
      buffer.writeln('        )),');
      buffer.writeln('        expect: () => [');
      buffer.writeln(
          '          // isA<${blocName}State>().having((s) => s.status, "status", ${blocName}Status.loading),');
      buffer.writeln(
          '          // isA<${blocName}State>().having((s) => s.status, "status", ${blocName}Status.loaded),');
      buffer.writeln('        ],');
      buffer.writeln('      );');

      // Error test
      buffer.writeln('');
      buffer.writeln(
          "      blocTest<$blocName, ${blocName}State>(");
      buffer.writeln(
          "        'emits [loading, error] when ${usecase.name.toCamelCase} fails',");
      buffer.writeln('        build: () {');
      buffer.writeln(
          '          // when(() => mock${usecase.name.toPascalCase}.call(');
      if (usecase.hasParams) {
        buffer.writeln(
            '          //   any(),');
      }
      buffer.writeln(
          "          // )).thenAnswer((_) async => (failure: Failure(message: 'error'), data: null));");
      buffer.writeln('          // return bloc;');
      buffer.writeln('          throw UnimplementedError();');
      buffer.writeln('        },');
      buffer.writeln(
          '        act: (bloc) => bloc.add(const ${usecase.name.toPascalCase}Event(');
      if (usecase.hasParams) {
        for (final param in usecase.params) {
          buffer.writeln(
              '          // ${param.name}: /* test value */,');
        }
      }
      buffer.writeln('        )),');
      buffer.writeln('        expect: () => [');
      buffer.writeln(
          '          // isA<${blocName}State>().having((s) => s.status, "status", ${blocName}Status.loading),');
      buffer.writeln(
          '          // isA<${blocName}State>().having((s) => s.status, "status", ${blocName}Status.error),');
      buffer.writeln('        ],');
      buffer.writeln('      );');

      buffer.writeln('    });');
    }

    buffer.writeln('  });');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate repository test.
  String generateRepositoryTest(FeatureConfig config) {
    final buffer = StringBuffer();
    final pascal = config.name.toPascalCase;
    final snake = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Repository Tests for feature "${config.name}"'));

    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:mocktail/mocktail.dart';");
    buffer.writeln('');
    buffer.writeln('// TODO: Update imports with your actual package name');
    buffer.writeln('// import "package:your_app/features/$snake/data/repositories/${snake}_repository_impl.dart";');
    if (config.hasApi) {
      buffer.writeln('// import "package:your_app/features/$snake/data/datasources/${snake}_remote_data_source.dart";');
    }
    buffer.writeln('');

    if (config.hasApi) {
      buffer.writeln(
          '// class Mock${pascal}RemoteDataSource extends Mock implements ${pascal}RemoteDataSource {}');
    }
    if (config.hasLocalDataSource) {
      buffer.writeln(
          '// class Mock${pascal}LocalDataSource extends Mock implements ${pascal}LocalDataSource {}');
    }
    buffer.writeln('');

    buffer.writeln('void main() {');
    buffer.writeln('  // late ${pascal}RepositoryImpl repository;');
    if (config.hasApi) {
      buffer.writeln(
          '  // late Mock${pascal}RemoteDataSource mockRemoteDataSource;');
    }
    buffer.writeln('');
    buffer.writeln('  setUp(() {');
    if (config.hasApi) {
      buffer.writeln(
          '    // mockRemoteDataSource = Mock${pascal}RemoteDataSource();');
    }
    buffer.writeln('    // repository = ${pascal}RepositoryImpl(');
    if (config.hasApi) {
      buffer.writeln(
          '    //   remoteDataSource: mockRemoteDataSource,');
    }
    buffer.writeln('    // );');
    buffer.writeln('  });');
    buffer.writeln('');

    for (final usecase in config.usecases) {
      buffer.writeln(
          "  group('${usecase.name.toCamelCase}', () {");
      buffer.writeln(
          "    test('returns data on success', () async {");
      buffer.writeln('      // Arrange');
      buffer.writeln('      // Act');
      buffer.writeln('      // Assert');
      buffer.writeln('    });');
      buffer.writeln('');
      buffer.writeln(
          "    test('returns failure on exception', () async {");
      buffer.writeln('      // Arrange');
      buffer.writeln('      // Act');
      buffer.writeln('      // Assert');
      buffer.writeln('    });');
      buffer.writeln('  });');
      buffer.writeln('');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
