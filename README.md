# MVLT Fastlane Configuration

Centralized Fastlane CI/CD configuration for MVLT iOS and macOS applications.

## Overview

This repository contains reusable Fastlane lanes and common actions for building, signing, and deploying MVLT apps to TestFlight. It eliminates code duplication and provides a single source of truth for CI/CD logic.

## Features

- ✅ **Hybrid Signing Strategy**: Manual signing for CI, automatic for local development
- ✅ **Environment-Aware**: Detects CI vs local and adapts behavior
- ✅ **Production Environment Variables**: Supports both GitHub Secrets and local .env files
- ✅ **Multi-Platform**: Separate Fastfiles for iOS and macOS
- ✅ **Reusable Actions**: Shared helper functions for common tasks
- ✅ **Fully Documented**: Comprehensive inline documentation

## Repository Structure

```
fastlane-config/
├── fastlane/
│   ├── Fastfile.ios          # iOS lanes (beta, build_only)
│   ├── Fastfile.macos        # macOS lanes (beta, build_only)
│   └── actions/
│       └── mvlt_common.rb    # Shared helper functions
├── README.md                  # This file
├── VERSION                    # Semantic version
├── CHANGELOG.md              # Version history
└── .gitignore                # Git ignore rules
```

## Usage

### In Your App Repository

Add to `ios/fastlane/Fastfile`:

```ruby
import_from_git(
  url: "git@github.com:MVLT-AI/fastlane-config.git",
  branch: "main",
  path: "fastlane/Fastfile.ios"
)
```

Add to `macos/fastlane/Fastfile`:

```ruby
import_from_git(
  url: "git@github.com:MVLT-AI/fastlane-config.git",
  branch: "main",
  path: "fastlane/Fastfile.macos"
)
```

### Running Lanes

**Deploy to TestFlight:**
```bash
cd ios && bundle exec fastlane beta
cd macos && bundle exec fastlane beta
```

**Build Only (No Upload):**
```bash
cd ios && bundle exec fastlane build_only
cd macos && bundle exec fastlane build_only
```

## Available Lanes

### iOS Platform

- **beta**: Build and deploy iOS app to TestFlight
  - Increments build number automatically
  - Uses hybrid signing (CI: manual, local: automatic)
  - Uploads to TestFlight with automated changelog

- **build_only**: Build iOS app without uploading
  - Same build process as beta
  - Skips TestFlight upload

### macOS Platform

- **beta**: Build and deploy macOS app to TestFlight
  - Increments build number automatically
  - Uses hybrid signing (CI: manual, local: automatic)
  - Uploads to TestFlight with automated changelog

- **build_only**: Build macOS app without uploading
  - Same build process as beta
  - Skips TestFlight upload

## Common Actions

All common actions are in `fastlane/actions/mvlt_common.rb`:

- `setup_shared_api_key` - Configure App Store Connect API authentication
- `setup_shared_ci_keychain` - Create CI keychain for code signing
- `setup_shared_cocoapods` - Install CocoaPods dependencies
- `common_export_options` - Generate common export options for builds
- `build_dart_defines_from_env` - Build Flutter --dart-define arguments
- `prepare_shared_flutter_for_ci` - Prepare Flutter for CI builds
- `cleanup_shared_keychain` - Clean up CI keychain on completion

See inline documentation in `mvlt_common.rb` for detailed usage.

## Environment Variables

### CI Environment (GitHub Actions)

Required GitHub Secrets:
- `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API Key ID
- `APP_STORE_CONNECT_API_ISSUER_ID` - App Store Connect Issuer ID
- `APP_STORE_CONNECT_API_KEY_PATH` - Path to .p8 key file
- `KEYCHAIN_PASSWORD` - Password for CI keychain
- `PROD_SUPABASE_URL` - Production Supabase URL
- `PROD_SUPABASE_ANON_KEY` - Production Supabase anon key
- `PROD_ANTHROPIC_API_KEY` - Production Claude API key

### Local Environment

Create `config/.env.production` in your app repository:

```bash
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
ANTHROPIC_API_KEY=your-claude-api-key
```

## Hybrid Signing Strategy

This configuration uses a hybrid approach to code signing:

**CI Environment (GitHub Actions):**
- Uses **manual signing** (no Apple ID required)
- Certificates and profiles pre-installed by workflow
- Profile names: `IOS` and `MACOS`
- Team ID: `ZR533W4VLM`

**Local Development:**
- Uses **automatic signing** (requires authenticated Apple ID in Xcode)
- Automatically downloads and installs profiles
- No manual certificate management needed

## Version Pinning (Future)

For production use, consider pinning to specific versions:

```ruby
import_from_git(
  url: "git@github.com:MVLT-AI/fastlane-config.git",
  version: "~> 1.0.0",  # Optimistic version constraint
  path: "fastlane/Fastfile.ios"
)
```

This allows testing updates before rollout.

## Development

### Making Changes

1. Clone this repository
2. Make your changes
3. Test with a sample app
4. Commit and push
5. Tag with semantic version: `git tag v1.1.0`
6. Push tags: `git push --tags`

### Testing Changes

Before pushing to main:

1. Test locally with a real app repository
2. Run both iOS and macOS builds
3. Verify CI/CD workflow still works
4. Check for regressions

## Contributing

This is an internal MVLT repository. Changes should be tested thoroughly before merging to main.

## License

Proprietary - MVLT AI © 2024

## Support

For issues or questions, contact the MVLT development team.
