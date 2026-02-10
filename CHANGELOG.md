## 1.0.1

- Fix: Shortened pubspec description to meet pub.dev 60-180 char requirement
- Fix: Escaped angle brackets in dartdoc comments to resolve pana warnings
- Fix: Added dartdoc comments to all public API members
- Added: `example/example.dart` with complete programmatic usage guide
- Improved: Documentation coverage now exceeds 90%

## 1.0.0

- 🎉 Initial release
- Generate complete Clean Architecture feature modules
- Support for BLoC and Cubit state management
- YAML-based configuration
- Entity generation with copyWith, equality, toString
- Model/DTO generation with JSON serialization
- Repository interface and implementation
- Remote and local data sources
- Use case classes with params
- BLoC with events, state, and handlers
- Screen widgets with loading/error/empty states
- Dependency injection setup (get_it compatible)
- Route configuration
- Unit test stubs with bloc_test and mocktail
- Barrel file generation
- Freezed support (optional)
- json_serializable support (optional)
- Programmatic API for custom tooling
- Comprehensive CLI with init, generate, and list commands
