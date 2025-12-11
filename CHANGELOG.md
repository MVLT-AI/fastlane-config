# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-11

### Added
- Initial release of centralized MVLT Fastlane configuration
- iOS Fastfile with `beta` and `build_only` lanes
- macOS Fastfile with `beta` and `build_only` lanes
- Shared common actions in `mvlt_common.rb`:
  - App Store Connect API authentication
  - CI keychain setup
  - CocoaPods installation
  - Flutter CI preparation
  - Environment variable loading (CI and local)
  - Dart define builder for production builds
- Hybrid signing strategy:
  - Manual signing for CI (no Apple ID required)
  - Automatic signing for local development
- Environment-aware builds:
  - Detects CI vs local environment
  - Loads from GitHub Secrets (CI) or .env file (local)
- Comprehensive documentation
- Semantic versioning support

### Features
- ✅ Automatic build number incrementation from TestFlight
- ✅ Production environment variable injection
- ✅ Code signing certificate validation
- ✅ Provisioning profile verification
- ✅ Flutter clean/prepare for CI builds
- ✅ TestFlight upload with automated changelog
- ✅ Build artifact cleanup
- ✅ Error handling and keychain cleanup

### Notes
- Extracted from MVLT app repository to reduce code duplication
- Total lines extracted: ~755 lines of Fastlane configuration
- Compatible with existing MVLT CI/CD pipeline
- No breaking changes to app repository workflow
