import '../models/feature_config.dart';
import '../utils/string_utils.dart';

/// Generates BLoC or Cubit classes for the presentation layer.
class BlocTemplate {
  const BlocTemplate();

  /// Generate BLoC with events and states.
  String generateBloc(FeatureConfig config) {
    final buffer = StringBuffer();
    final blocName = '${config.name.toPascalCase}Bloc';
    final snakeName = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'BLoC for feature "${config.name}"'));

    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    buffer.writeln("import '${snakeName}_event.dart';");
    buffer.writeln("import '${snakeName}_state.dart';");

    // Import use cases
    for (final usecase in config.usecases) {
      buffer.writeln(
          "import '../../domain/usecases/${usecase.name.toSnakeCase}_usecase.dart';");
    }
    buffer.writeln('');

    buffer.writeln('/// BLoC for ${config.name.toPascalCase} feature.');
    buffer.writeln('///');
    buffer.writeln('/// Handles all business events and emits corresponding states.');
    buffer.writeln('class $blocName extends Bloc<${blocName}Event, ${blocName}State> {');

    // Use case fields
    for (final usecase in config.usecases) {
      buffer.writeln(
          '  final ${usecase.name.toPascalCase} _${usecase.name.toCamelCase};');
    }
    buffer.writeln('');

    // Constructor
    buffer.writeln('  $blocName({');
    for (final usecase in config.usecases) {
      buffer.writeln(
          '    required ${usecase.name.toPascalCase} ${usecase.name.toCamelCase},');
    }
    buffer.writeln('  })');
    final assignments = config.usecases
        .map((u) => '_${u.name.toCamelCase} = ${u.name.toCamelCase}')
        .toList();
    if (assignments.isNotEmpty) {
      buffer.writeln('      : ${assignments.join(',\n        ')},');
    } else {
      buffer.writeln('      :');
    }
    buffer.writeln('        super(const ${blocName}State.initial()) {');

    // Register event handlers
    for (final usecase in config.usecases) {
      buffer.writeln(
          '    on<${usecase.name.toPascalCase}Event>(_on${usecase.name.toPascalCase});');
    }
    buffer.writeln('  }');

    // Event handlers
    for (final usecase in config.usecases) {
      buffer.writeln('');
      buffer.writeln(
          '  Future<void> _on${usecase.name.toPascalCase}(');
      buffer.writeln(
          '    ${usecase.name.toPascalCase}Event event,');
      buffer.writeln(
          '    Emitter<${blocName}State> emit,');
      buffer.writeln('  ) async {');
      buffer.writeln(
          '    emit(state.copyWith(status: ${blocName}Status.loading));');
      buffer.writeln('');
      buffer.writeln('    try {');

      if (usecase.hasParams) {
        buffer.writeln(
            '      final result = await _${usecase.name.toCamelCase}.call(');
        buffer.writeln(
            '        ${usecase.name.toPascalCase}Params(');
        for (final param in usecase.params) {
          buffer.writeln(
              '          ${param.name}: event.${param.name},');
        }
        buffer.writeln('        ),');
        buffer.writeln('      );');
      } else {
        buffer.writeln(
            '      final result = await _${usecase.name.toCamelCase}.call();');
      }

      buffer.writeln('');
      if (usecase.useEither) {
        buffer.writeln('      if (result.failure != null) {');
        buffer.writeln('        emit(state.copyWith(');
        buffer.writeln(
            '          status: ${blocName}Status.error,');
        buffer.writeln(
            '          errorMessage: result.failure!.message,');
        buffer.writeln('        ));');
        buffer.writeln('      } else {');
        buffer.writeln('        emit(state.copyWith(');
        buffer.writeln(
            '          status: ${blocName}Status.loaded,');
        if (!usecase.isVoid) {
          buffer.writeln(
              '          // TODO: Update state with result.data');
        }
        buffer.writeln('        ));');
        buffer.writeln('      }');
      } else {
        buffer.writeln('      emit(state.copyWith(');
        buffer.writeln(
            '        status: ${blocName}Status.loaded,');
        buffer.writeln('      ));');
      }

      buffer.writeln('    } catch (e) {');
      buffer.writeln('      emit(state.copyWith(');
      buffer.writeln(
          '        status: ${blocName}Status.error,');
      buffer.writeln(
          '        errorMessage: e.toString(),');
      buffer.writeln('      ));');
      buffer.writeln('    }');
      buffer.writeln('  }');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate BLoC events.
  String generateEvents(FeatureConfig config) {
    final buffer = StringBuffer();
    final blocName = '${config.name.toPascalCase}Bloc';

    buffer.write(StringUtils.fileHeader(
        'Events for ${config.name.toPascalCase} BLoC'));

    buffer.writeln('/// Base event for $blocName.');
    buffer.writeln('sealed class ${blocName}Event {');
    buffer.writeln('  const ${blocName}Event();');
    buffer.writeln('}');

    for (final usecase in config.usecases) {
      buffer.writeln('');
      buffer.writeln('/// Event to trigger ${usecase.name.toPascalCase} operation.');
      buffer.writeln(
          'final class ${usecase.name.toPascalCase}Event extends ${blocName}Event {');
      for (final param in usecase.params) {
        buffer.writeln('  final ${param.type} ${param.name};');
      }
      if (usecase.hasParams) {
        buffer.writeln('');
        buffer.writeln(
            '  const ${usecase.name.toPascalCase}Event({');
        for (final param in usecase.params) {
          buffer.writeln('    required this.${param.name},');
        }
        buffer.writeln('  });');
      } else {
        buffer.writeln(
            '  const ${usecase.name.toPascalCase}Event();');
      }
      buffer.writeln('}');
    }

    return buffer.toString();
  }

  /// Generate BLoC state.
  String generateState(FeatureConfig config) {
    final buffer = StringBuffer();
    final blocName = '${config.name.toPascalCase}Bloc';

    buffer.write(StringUtils.fileHeader(
        'State for ${config.name.toPascalCase} BLoC'));

    // Import entity types
    for (final model in config.models) {
      buffer.writeln(
          "import '../../domain/entities/${model.name.toSnakeCase}_entity.dart';");
    }
    buffer.writeln('');

    // Status enum
    buffer.writeln('/// Status of the ${config.name.toPascalCase} feature.');
    buffer.writeln('enum ${blocName}Status {');
    buffer.writeln('  initial,');
    buffer.writeln('  loading,');
    buffer.writeln('  loaded,');
    buffer.writeln('  error,');
    buffer.writeln('}');
    buffer.writeln('');

    // State class
    buffer.writeln('/// State for [$blocName].');
    buffer.writeln('class ${blocName}State {');
    buffer.writeln('  final ${blocName}Status status;');
    buffer.writeln('  final String? errorMessage;');

    // Add fields for each model type
    for (final model in config.models) {
      buffer.writeln('  final ${model.name}? ${model.name.toCamelCase};');
      buffer.writeln(
          '  final List<${model.name}> ${model.name.toCamelCase}List;');
    }
    buffer.writeln('');

    // Constructor
    buffer.writeln('  const ${blocName}State({');
    buffer.writeln(
        '    this.status = ${blocName}Status.initial,');
    buffer.writeln('    this.errorMessage,');
    for (final model in config.models) {
      buffer.writeln('    this.${model.name.toCamelCase},');
      buffer.writeln(
          '    this.${model.name.toCamelCase}List = const [],');
    }
    buffer.writeln('  });');
    buffer.writeln('');

    // Named constructor for initial state
    buffer.writeln('  const ${blocName}State.initial()');
    buffer.writeln(
        '      : status = ${blocName}Status.initial,');
    buffer.writeln('        errorMessage = null');
    for (final model in config.models) {
      buffer.writeln(
          ',\n        ${model.name.toCamelCase} = null');
      buffer.writeln(
          ',\n        ${model.name.toCamelCase}List = const []');
    }
    buffer.writeln(';');
    buffer.writeln('');

    // copyWith
    buffer.writeln('  ${blocName}State copyWith({');
    buffer.writeln('    ${blocName}Status? status,');
    buffer.writeln('    String? errorMessage,');
    for (final model in config.models) {
      buffer.writeln('    ${model.name}? ${model.name.toCamelCase},');
      buffer.writeln(
          '    List<${model.name}>? ${model.name.toCamelCase}List,');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return ${blocName}State(');
    buffer.writeln('      status: status ?? this.status,');
    buffer.writeln(
        '      errorMessage: errorMessage ?? this.errorMessage,');
    for (final model in config.models) {
      buffer.writeln(
          '      ${model.name.toCamelCase}: ${model.name.toCamelCase} ?? this.${model.name.toCamelCase},');
      buffer.writeln(
          '      ${model.name.toCamelCase}List: ${model.name.toCamelCase}List ?? this.${model.name.toCamelCase}List,');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate Cubit (alternative to BLoC).
  String generateCubit(FeatureConfig config) {
    final buffer = StringBuffer();
    final cubitName = '${config.name.toPascalCase}Cubit';
    final blocName = '${config.name.toPascalCase}Bloc';
    final snakeName = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Cubit for feature "${config.name}"'));

    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    buffer.writeln("import '${snakeName}_state.dart';");

    for (final usecase in config.usecases) {
      buffer.writeln(
          "import '../../domain/usecases/${usecase.name.toSnakeCase}_usecase.dart';");
    }
    buffer.writeln('');

    buffer.writeln('/// Cubit for ${config.name.toPascalCase} feature.');
    buffer.writeln('class $cubitName extends Cubit<${blocName}State> {');

    for (final usecase in config.usecases) {
      buffer.writeln(
          '  final ${usecase.name.toPascalCase} _${usecase.name.toCamelCase};');
    }
    buffer.writeln('');

    // Constructor
    buffer.writeln('  $cubitName({');
    for (final usecase in config.usecases) {
      buffer.writeln(
          '    required ${usecase.name.toPascalCase} ${usecase.name.toCamelCase},');
    }
    buffer.writeln('  })');
    final assignments = config.usecases
        .map((u) => '_${u.name.toCamelCase} = ${u.name.toCamelCase}')
        .toList();
    if (assignments.isNotEmpty) {
      buffer.writeln('      : ${assignments.join(',\n        ')},');
    } else {
      buffer.writeln('      :');
    }
    buffer.writeln('        super(const ${blocName}State.initial());');

    // Methods for each use case
    for (final usecase in config.usecases) {
      buffer.writeln('');
      final params = usecase.params
          .map((p) => '${p.type} ${p.name}')
          .join(', ');
      buffer.writeln(
          '  Future<void> ${usecase.name.toCamelCase}($params) async {');
      buffer.writeln(
          '    emit(state.copyWith(status: ${blocName}Status.loading));');
      buffer.writeln('');
      buffer.writeln('    try {');

      if (usecase.hasParams) {
        buffer.writeln(
            '      final result = await _${usecase.name.toCamelCase}.call(');
        buffer.writeln(
            '        ${usecase.name.toPascalCase}Params(');
        for (final param in usecase.params) {
          buffer.writeln('          ${param.name}: ${param.name},');
        }
        buffer.writeln('        ),');
        buffer.writeln('      );');
      } else {
        buffer.writeln(
            '      final result = await _${usecase.name.toCamelCase}.call();');
      }

      buffer.writeln('');
      if (usecase.useEither) {
        buffer.writeln('      if (result.failure != null) {');
        buffer.writeln('        emit(state.copyWith(');
        buffer.writeln(
            '          status: ${blocName}Status.error,');
        buffer.writeln(
            '          errorMessage: result.failure!.message,');
        buffer.writeln('        ));');
        buffer.writeln('      } else {');
        buffer.writeln('        emit(state.copyWith(');
        buffer.writeln(
            '          status: ${blocName}Status.loaded,');
        buffer.writeln('        ));');
        buffer.writeln('      }');
      } else {
        buffer.writeln('      emit(state.copyWith(');
        buffer.writeln(
            '        status: ${blocName}Status.loaded,');
        buffer.writeln('      ));');
      }

      buffer.writeln('    } catch (e) {');
      buffer.writeln('      emit(state.copyWith(');
      buffer.writeln(
          '        status: ${blocName}Status.error,');
      buffer.writeln(
          '        errorMessage: e.toString(),');
      buffer.writeln('      ));');
      buffer.writeln('    }');
      buffer.writeln('  }');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
