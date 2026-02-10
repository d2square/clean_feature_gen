import 'dart:io';
import 'package:test/test.dart';
import 'package:clean_feature_gen/clean_feature_gen.dart';

void main() {
  group('FeatureConfig', () {
    test('validates feature name correctly', () {
      const config = FeatureConfig(name: 'user_profile');
      expect(config.validate(), isEmpty);
    });

    test('rejects invalid feature name', () {
      const config = FeatureConfig(name: 'UserProfile');
      expect(config.validate(), isNotEmpty);
    });

    test('rejects empty feature name', () {
      const config = FeatureConfig(name: '');
      expect(config.validate(), isNotEmpty);
    });

    test('parses from YAML map', () {
      final yaml = {
        'feature': 'login',
        'state_management': 'bloc',
        'has_api': true,
        'api_base': '/api/v1/auth',
        'generate_tests': true,
        'models': [
          {
            'name': 'User',
            'fields': [
              {'name': 'id', 'type': 'int'},
              {'name': 'email', 'type': 'String'},
            ],
          }
        ],
        'usecases': [
          {
            'name': 'LoginUser',
            'return_type': 'User',
            'params': [
              {'name': 'email', 'type': 'String'},
              {'name': 'password', 'type': 'String'},
            ],
          }
        ],
        'screens': [
          {'name': 'LoginScreen', 'type': 'stateful'},
        ],
      };

      final config = FeatureConfig.fromYaml(yaml);

      expect(config.name, 'login');
      expect(config.stateManagement, StateManagement.bloc);
      expect(config.hasApi, true);
      expect(config.apiBase, '/api/v1/auth');
      expect(config.models.length, 1);
      expect(config.models.first.name, 'User');
      expect(config.models.first.fields.length, 2);
      expect(config.usecases.length, 1);
      expect(config.usecases.first.name, 'LoginUser');
      expect(config.usecases.first.params.length, 2);
      expect(config.screens.length, 1);
      expect(config.screens.first.name, 'LoginScreen');
    });
  });

  group('ModelDefinition', () {
    test('validates correctly', () {
      const model = ModelDefinition(
        name: 'User',
        fields: [FieldDefinition(name: 'id', type: 'int')],
      );
      expect(model.validate(), isEmpty);
    });

    test('rejects empty name', () {
      const model = ModelDefinition(
        name: '',
        fields: [FieldDefinition(name: 'id', type: 'int')],
      );
      expect(model.validate(), isNotEmpty);
    });

    test('rejects non-PascalCase name', () {
      const model = ModelDefinition(
        name: 'user_model',
        fields: [FieldDefinition(name: 'id', type: 'int')],
      );
      expect(model.validate(), isNotEmpty);
    });

    test('rejects empty fields', () {
      const model = ModelDefinition(name: 'User', fields: []);
      expect(model.validate(), isNotEmpty);
    });
  });

  group('FieldDefinition', () {
    test('detects nullable type', () {
      const field = FieldDefinition(name: 'avatar', type: 'String?');
      expect(field.isNullable, true);
      expect(field.baseType, 'String');
    });

    test('detects non-nullable type', () {
      const field = FieldDefinition(name: 'name', type: 'String');
      expect(field.isNullable, false);
      expect(field.baseType, 'String');
    });

    test('detects list type', () {
      const field = FieldDefinition(name: 'tags', type: 'List<String>');
      expect(field.isList, true);
    });

    test('detects primitive type', () {
      expect(
        const FieldDefinition(name: 'x', type: 'String').isPrimitive,
        true,
      );
      expect(
        const FieldDefinition(name: 'x', type: 'int').isPrimitive,
        true,
      );
      expect(
        const FieldDefinition(name: 'x', type: 'User').isPrimitive,
        false,
      );
    });
  });

  group('UsecaseDefinition', () {
    test('validates correctly', () {
      const uc = UsecaseDefinition(name: 'GetUser', returnType: 'User');
      expect(uc.validate(), isEmpty);
    });

    test('detects void return', () {
      const uc = UsecaseDefinition(name: 'DeleteUser', returnType: 'void');
      expect(uc.isVoid, true);
    });

    test('detects params', () {
      const uc = UsecaseDefinition(
        name: 'GetUser',
        params: [ParamDefinition(name: 'id', type: 'int')],
      );
      expect(uc.hasParams, true);
    });
  });

  group('StringUtils', () {
    test('toSnakeCase', () {
      expect('UserProfile'.toSnakeCase, 'user_profile');
      expect('getUserProfile'.toSnakeCase, 'get_user_profile');
    });

    test('toPascalCase', () {
      expect('user_profile'.toPascalCase, 'UserProfile');
    });

    test('toCamelCase', () {
      expect('GetUserProfile'.toCamelCase, 'getUserProfile');
      expect('user_profile'.toCamelCase, 'userProfile');
    });
  });

  group('FeatureGenerator', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('clean_gen_test_');
      File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: test_app');
      Directory('${tempDir.path}/lib').createSync();
      Directory('${tempDir.path}/test').createSync();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('generates all files for a basic feature', () async {
      const config = FeatureConfig(
        name: 'login',
        stateManagement: StateManagement.bloc,
        hasApi: true,
        apiBase: '/api/v1/auth',
        models: [
          ModelDefinition(
            name: 'User',
            fields: [
              FieldDefinition(name: 'id', type: 'int'),
              FieldDefinition(name: 'email', type: 'String'),
            ],
          ),
        ],
        usecases: [
          UsecaseDefinition(
            name: 'LoginUser',
            returnType: 'User',
            params: [
              ParamDefinition(name: 'email', type: 'String'),
              ParamDefinition(name: 'password', type: 'String'),
            ],
          ),
        ],
        screens: [
          ScreenDefinition(name: 'LoginScreen'),
        ],
      );

      final generator = FeatureGenerator(
        config: config,
        projectRoot: tempDir.path,
        logger: const Logger(verbose: false),
      );

      await generator.generate();

      final featureDir = '${tempDir.path}/lib/features/login';

      expect(File('$featureDir/domain/entities/user_entity.dart').existsSync(),
          true);
      expect(File('$featureDir/domain/entities/failure.dart').existsSync(),
          true);
      expect(
          File('$featureDir/domain/repositories/login_repository.dart')
              .existsSync(),
          true);
      expect(
          File('$featureDir/domain/usecases/login_user_usecase.dart')
              .existsSync(),
          true);
      expect(
          File('$featureDir/data/models/user_model.dart').existsSync(), true);
      expect(
          File('$featureDir/data/datasources/login_remote_data_source.dart')
              .existsSync(),
          true);
      expect(
          File('$featureDir/data/repositories/login_repository_impl.dart')
              .existsSync(),
          true);
      expect(
          File('$featureDir/presentation/bloc/login_bloc.dart').existsSync(),
          true);
      expect(
          File('$featureDir/presentation/bloc/login_event.dart').existsSync(),
          true);
      expect(
          File('$featureDir/presentation/bloc/login_state.dart').existsSync(),
          true);
      expect(
          File('$featureDir/presentation/screens/login_screen.dart')
              .existsSync(),
          true);
      expect(
          File('$featureDir/di/login_injection.dart').existsSync(), true);
      expect(
          File('$featureDir/routes/login_routes.dart').existsSync(), true);
      expect(File('$featureDir/login.dart').existsSync(), true);

      expect(
          File('${tempDir.path}/test/features/login/login_bloc_test.dart')
              .existsSync(),
          true);
      expect(
          File('${tempDir.path}/test/features/login/login_repository_test.dart')
              .existsSync(),
          true);
    });

    test('does not overwrite existing files by default', () async {
      const config = FeatureConfig(
        name: 'simple',
        models: [
          ModelDefinition(
            name: 'Item',
            fields: [FieldDefinition(name: 'id', type: 'int')],
          ),
        ],
      );

      final generator = FeatureGenerator(
        config: config,
        projectRoot: tempDir.path,
        logger: const Logger(verbose: false),
      );

      await generator.generate();

      final entityFile = File(
          '${tempDir.path}/lib/features/simple/domain/entities/item_entity.dart');

      entityFile.writeAsStringSync('// modified');

      final generator2 = FeatureGenerator(
        config: config,
        projectRoot: tempDir.path,
        logger: const Logger(verbose: false),
      );
      await generator2.generate();

      expect(entityFile.readAsStringSync(), '// modified');
    });

    test('overwrites files when flag is set', () async {
      const config = FeatureConfig(
        name: 'overwrite_test',
        models: [
          ModelDefinition(
            name: 'Data',
            fields: [FieldDefinition(name: 'id', type: 'int')],
          ),
        ],
      );

      final generator = FeatureGenerator(
        config: config,
        projectRoot: tempDir.path,
        logger: const Logger(verbose: false),
      );
      await generator.generate();

      final entityFile = File(
          '${tempDir.path}/lib/features/overwrite_test/domain/entities/data_entity.dart');
      entityFile.writeAsStringSync('// modified');

      final generator2 = FeatureGenerator(
        config: config,
        projectRoot: tempDir.path,
        overwrite: true,
        logger: const Logger(verbose: false),
      );
      await generator2.generate();

      expect(entityFile.readAsStringSync(), isNot('// modified'));
    });
  });
}
