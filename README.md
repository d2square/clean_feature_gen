# clean_feature_gen

[![pub package](https://img.shields.io/pub/v/clean_feature_gen.svg)](https://pub.dev/packages/clean_feature_gen)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A powerful CLI tool for generating **complete Clean Architecture feature modules** in Flutter with BLoC/Cubit support.

**Stop writing boilerplate. Start shipping features.**

One command generates **15+ files** — entities, models, repositories, data sources, use cases, BLoC/Cubit, screens, DI setup, routes, and unit tests — all following Clean Architecture best practices.

## ⏱️ Time Saved

| Task | Manual | With clean_feature_gen |
|------|--------|-----------------------|
| New feature setup | 30-60 min | **< 10 seconds** |
| Consistency across team | Variable | **100% consistent** |
| Onboarding new developer | Hours | **Minutes** |

## 🚀 Quick Start

### Install

```bash
dart pub global activate clean_feature_gen
```

### Create a config file

```bash
clean_feature_gen init
```

### Generate a feature

```bash
# From YAML config (recommended for complex features)
clean_feature_gen generate --config feature_config.yaml

# Quick inline generation
clean_feature_gen generate --name login --state-management bloc --has-api

# With all options
clean_feature_gen generate \
  --name user_profile \
  --state-management bloc \
  --has-api \
  --api-base /api/v1/users \
  --generate-tests \
  --local-data-source \
  --overwrite
```

## 📁 Generated Structure

```
lib/features/user_profile/
│
├── domain/                              # Pure Dart — zero dependencies
│   ├── entities/
│   │   ├── user_profile_entity.dart     # Entity with copyWith, equality
│   │   └── failure.dart                 # Typed failure classes
│   ├── repositories/
│   │   └── user_profile_repository.dart # Abstract contract
│   └── usecases/
│       ├── get_user_profile_usecase.dart
│       └── update_user_profile_usecase.dart
│
├── data/                                # External integrations
│   ├── models/
│   │   └── user_profile_model.dart      # DTO with JSON + entity mapper
│   ├── datasources/
│   │   ├── user_profile_remote_data_source.dart
│   │   └── user_profile_local_data_source.dart
│   └── repositories/
│       └── user_profile_repository_impl.dart
│
├── presentation/                        # Flutter UI
│   ├── bloc/
│   │   ├── user_profile_bloc.dart       # Event handlers
│   │   ├── user_profile_event.dart      # Sealed events
│   │   └── user_profile_state.dart      # Status-based state
│   ├── screens/
│   │   └── user_profile_screen.dart     # BLoC-integrated screen
│   └── widgets/
│
├── di/
│   └── user_profile_injection.dart      # get_it / injectable setup
├── routes/
│   └── user_profile_routes.dart
└── user_profile.dart                    # Barrel exports

test/features/user_profile/
├── user_profile_bloc_test.dart          # bloc_test + mocktail stubs
└── user_profile_repository_test.dart
```

## 📝 YAML Configuration

```yaml
feature: transfer_beneficiary
state_management: bloc
has_api: true
api_base: /api/v1/beneficiaries
generate_tests: true
generate_di: true
generate_routes: true
use_json_serializable: true
has_local_data_source: true

models:
  - name: Beneficiary
    fields:
      - name: id
        type: int
      - name: fullName
        type: String
        json_key: full_name
      - name: iban
        type: String
      - name: bankCode
        type: String?
        json_key: bank_code
      - name: isActive
        type: bool
        default: "true"

usecases:
  - name: GetBeneficiaries
    return_type: List<Beneficiary>
  - name: AddBeneficiary
    return_type: Beneficiary
    params:
      - name: beneficiary
        type: Beneficiary
  - name: DeleteBeneficiary
    return_type: void
    params:
      - name: id
        type: int

screens:
  - name: BeneficiaryListScreen
    type: stateless
    has_app_bar: true
    pull_to_refresh: true
  - name: AddBeneficiaryScreen
    type: stateful
```

## ⚙️ Configuration Reference

### Feature Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `feature` | String | required | Feature name (snake_case) |
| `state_management` | String | `bloc` | `bloc` or `cubit` |
| `has_api` | bool | `true` | Generate remote data source |
| `api_base` | String | auto | API endpoint path |
| `generate_tests` | bool | `true` | Generate test stubs |
| `generate_di` | bool | `true` | Generate DI setup |
| `generate_routes` | bool | `true` | Generate route config |
| `use_freezed` | bool | `false` | Use Freezed for models |
| `use_json_serializable` | bool | `true` | Use json_serializable |
| `has_local_data_source` | bool | `false` | Local caching layer |
| `base_path` | String | `lib/features` | Output directory |

### Model Fields

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | String | required | Field name (camelCase) |
| `type` | String | required | Dart type (String, int, bool, List<T>, T?) |
| `json_key` | String | auto | JSON key name |
| `default` | String | null | Default value expression |
| `required` | bool | `true` | Required in constructor |

### Use Case Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | String | required | PascalCase name |
| `return_type` | String | `void` | Return type |
| `params` | List | `[]` | Parameters |
| `is_stream` | bool | `false` | Stream-based use case |
| `use_either` | bool | `true` | Wrap in result tuple |

## 🔧 Programmatic Usage

```dart
import 'package:clean_feature_gen/clean_feature_gen.dart';

final config = FeatureConfig(
  name: 'payment',
  stateManagement: StateManagement.bloc,
  hasApi: true,
  apiBase: '/api/v1/payments',
  models: [
    ModelDefinition(
      name: 'Payment',
      fields: [
        FieldDefinition(name: 'id', type: 'int'),
        FieldDefinition(name: 'amount', type: 'double'),
        FieldDefinition(name: 'currency', type: 'String'),
      ],
    ),
  ],
  usecases: [
    UsecaseDefinition(
      name: 'ProcessPayment',
      returnType: 'Payment',
      params: [ParamDefinition(name: 'amount', type: 'double')],
    ),
  ],
  screens: [
    ScreenDefinition(name: 'PaymentScreen'),
  ],
);

final generator = FeatureGenerator(
  config: config,
  projectRoot: '/path/to/project',
);
await generator.generate();
```

## 🏦 Real-World Example: Banking App

```yaml
feature: international_transfer
state_management: bloc
has_api: true
api_base: /api/v1/transfers/international
has_local_data_source: true

models:
  - name: InternationalTransfer
    fields:
      - name: id
        type: String
      - name: amount
        type: double
      - name: currency
        type: String
      - name: beneficiaryId
        type: String
        json_key: beneficiary_id
      - name: status
        type: String
      - name: reference
        type: String?

usecases:
  - name: InitiateTransfer
    return_type: InternationalTransfer
    params:
      - name: transfer
        type: InternationalTransfer
  - name: GetTransferStatus
    return_type: InternationalTransfer
    params:
      - name: transferId
        type: String
  - name: GetTransferHistory
    return_type: List<InternationalTransfer>
  - name: CancelTransfer
    return_type: void
    params:
      - name: transferId
        type: String

screens:
  - name: TransferFormScreen
    type: stateful
    pull_to_refresh: false
  - name: TransferHistoryScreen
    type: stateless
    pull_to_refresh: true
  - name: TransferDetailScreen
    type: stateless
```

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines first.

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
