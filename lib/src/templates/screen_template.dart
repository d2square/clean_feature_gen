import '../models/feature_config.dart';
import '../models/screen_definition.dart';
import '../utils/string_utils.dart';

/// Generates screen/page widget files.
class ScreenTemplate {
  const ScreenTemplate();

  String generate(ScreenDefinition screen, FeatureConfig config) {
    final buffer = StringBuffer();
    final blocName = '${config.name.toPascalCase}Bloc';
    final snakeName = config.name.toSnakeCase;

    buffer.write(StringUtils.fileHeader(
        'Screen: ${screen.name} for feature "${config.name}"'));

    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");

    if (config.stateManagement == StateManagement.bloc) {
      buffer.writeln("import '../bloc/${snakeName}_bloc.dart';");
      buffer.writeln("import '../bloc/${snakeName}_event.dart';");
    } else {
      buffer.writeln("import '../cubit/${snakeName}_cubit.dart';");
    }
    buffer.writeln("import '../bloc/${snakeName}_state.dart';");
    buffer.writeln('');

    final screenClass = screen.type == ScreenType.stateless
        ? 'StatelessWidget'
        : 'StatefulWidget';

    buffer.writeln('/// ${screen.name} screen for ${config.name.toPascalCase}.');
    buffer.writeln('class ${screen.name} extends $screenClass {');
    buffer.writeln('  const ${screen.name}({super.key});');
    buffer.writeln('');
    buffer.writeln(
        "  static const routeName = '/${snakeName}/${screen.name.toSnakeCase}';");
    buffer.writeln('');

    if (screen.type == ScreenType.stateful) {
      buffer.writeln('  @override');
      buffer.writeln(
          '  State<${screen.name}> createState() => _${screen.name}State();');
      buffer.writeln('}');
      buffer.writeln('');
      buffer.writeln(
          'class _${screen.name}State extends State<${screen.name}> {');
      buffer.writeln('  @override');
      buffer.writeln('  void initState() {');
      buffer.writeln('    super.initState();');
      buffer.writeln('    // TODO: Dispatch initial events');
      buffer.writeln('  }');
      buffer.writeln('');
    }

    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Scaffold(');

    if (screen.hasAppBar) {
      buffer.writeln('      appBar: AppBar(');
      buffer.writeln(
          "        title: const Text('${_humanReadableName(screen.name)}'),");
      buffer.writeln('      ),');
    }

    if (screen.hasPullToRefresh) {
      buffer.writeln('      body: RefreshIndicator(');
      buffer.writeln('        onRefresh: () async {');
      buffer.writeln('          // TODO: Dispatch refresh event');
      buffer.writeln('        },');
      buffer.writeln(
          '        child: _buildBody(context),');
      buffer.writeln('      ),');
    } else {
      buffer.writeln('      body: _buildBody(context),');
    }

    buffer.writeln('    );');
    buffer.writeln('  }');

    // _buildBody
    buffer.writeln('');
    buffer.writeln('  Widget _buildBody(BuildContext context) {');
    buffer.writeln(
        '    return BlocConsumer<$blocName, ${blocName}State>(');
    buffer.writeln('      listener: (context, state) {');
    buffer.writeln(
        '        if (state.status == ${blocName}Status.error && state.errorMessage != null) {');
    buffer.writeln(
        '          ScaffoldMessenger.of(context).showSnackBar(');
    buffer.writeln(
        "            SnackBar(content: Text(state.errorMessage!)),");
    buffer.writeln('          );');
    buffer.writeln('        }');
    buffer.writeln('      },');
    buffer.writeln('      builder: (context, state) {');
    buffer.writeln('        return switch (state.status) {');
    buffer.writeln(
        '          ${blocName}Status.loading => const Center(child: CircularProgressIndicator()),');
    buffer.writeln(
        '          ${blocName}Status.error => _ErrorView(message: state.errorMessage, onRetry: () {');
    buffer.writeln('            // TODO: Dispatch retry event');
    buffer.writeln('          }),');
    buffer.writeln(
        '          ${blocName}Status.loaded => _ContentView(state: state),');
    buffer.writeln(
        '          ${blocName}Status.initial => const _InitialView(),');
    buffer.writeln('        };');
    buffer.writeln('      },');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    // Sub-widgets
    buffer.writeln('');
    buffer.writeln('class _InitialView extends StatelessWidget {');
    buffer.writeln('  const _InitialView();');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln(
        "    return const Center(child: Text('Welcome'));");
    buffer.writeln('  }');
    buffer.writeln('}');

    buffer.writeln('');
    buffer.writeln('class _ContentView extends StatelessWidget {');
    buffer.writeln('  final ${blocName}State state;');
    buffer.writeln('  const _ContentView({required this.state});');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    // TODO: Build UI with state data');
    buffer.writeln(
        "    return const Center(child: Text('Content loaded'));");
    buffer.writeln('  }');
    buffer.writeln('}');

    buffer.writeln('');
    buffer.writeln('class _ErrorView extends StatelessWidget {');
    buffer.writeln('  final String? message;');
    buffer.writeln('  final VoidCallback? onRetry;');
    buffer.writeln('  const _ErrorView({this.message, this.onRetry});');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Center(');
    buffer.writeln('      child: Column(');
    buffer.writeln(
        '        mainAxisAlignment: MainAxisAlignment.center,');
    buffer.writeln('        children: [');
    buffer.writeln(
        '          const Icon(Icons.error_outline, size: 48, color: Colors.red),');
    buffer.writeln('          const SizedBox(height: 16),');
    buffer.writeln(
        "          Text(message ?? 'Something went wrong', textAlign: TextAlign.center),");
    buffer.writeln(
        '          if (onRetry != null) ...[');
    buffer.writeln('            const SizedBox(height: 16),');
    buffer.writeln(
        "            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),");
    buffer.writeln('          ],');
    buffer.writeln('        ],');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _humanReadableName(String name) {
    return name
        .replaceAll('Screen', '')
        .replaceAll('Page', '')
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim();
  }
}
