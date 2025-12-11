# ===============================================
# MVLT Common Fastlane Actions
# ===============================================
# Shared helper functions used across iOS and macOS platforms.
# This file is automatically imported by Fastlane from the actions/ directory.
#
# Repository: github.com/MVLT-AI/fastlane-config
# ===============================================

# -----------------------------------------------
# App Store Connect API Authentication
# -----------------------------------------------
# Sets up API key for authentication with App Store Connect.
# Validates required environment variables and configures the API key.
#
# Required Environment Variables:
#   - APP_STORE_CONNECT_API_KEY_ID: Your API key ID
#   - APP_STORE_CONNECT_API_ISSUER_ID: Your issuer ID
#   - APP_STORE_CONNECT_API_KEY_PATH: Path to the .p8 key file
#
# Usage:
#   setup_shared_api_key
def setup_shared_api_key
  # Validate required environment variables
  unless ENV['APP_STORE_CONNECT_API_KEY_ID'] && ENV['APP_STORE_CONNECT_API_ISSUER_ID'] && ENV['APP_STORE_CONNECT_API_KEY_PATH']
    FastlaneCore::UI.user_error!("Missing required API key environment variables")
  end

  unless File.exist?(ENV['APP_STORE_CONNECT_API_KEY_PATH'])
    FastlaneCore::UI.user_error!("API key file not found at: #{ENV['APP_STORE_CONNECT_API_KEY_PATH']}")
  end

  puts "🔑 Setting up App Store Connect API key..."
  puts "   Key ID: #{ENV['APP_STORE_CONNECT_API_KEY_ID']}"
  puts "   Issuer ID: #{ENV['APP_STORE_CONNECT_API_ISSUER_ID']}"
  puts "   Key Path: #{ENV['APP_STORE_CONNECT_API_KEY_PATH']}"

  app_store_connect_api_key(
    key_id: ENV['APP_STORE_CONNECT_API_KEY_ID'],
    issuer_id: ENV['APP_STORE_CONNECT_API_ISSUER_ID'],
    key_filepath: ENV['APP_STORE_CONNECT_API_KEY_PATH'],
    in_house: false,
    duration: 1200  # 20 minutes - longer than default
  )

  puts "✅ API key configured successfully"
end

# -----------------------------------------------
# CI Keychain Setup
# -----------------------------------------------
# Creates and configures a temporary keychain for CI builds.
# This keychain is used to store certificates and signing identities.
#
# Environment Variables:
#   - KEYCHAIN_PASSWORD: Password for the CI keychain (optional, defaults to temp password)
#
# Usage:
#   setup_shared_ci_keychain
def setup_shared_ci_keychain
  keychain_name = "ci_keychain"
  keychain_password = ENV['KEYCHAIN_PASSWORD'] || "ci_temp_password"

  create_keychain(
    name: keychain_name,
    password: keychain_password,
    default_keychain: false,  # Don't make this the default - keep login keychain
    unlock: true,
    timeout: 3600,
    lock_when_sleeps: false,
    add_to_search_list: true
  )

  puts "✅ CI keychain configured successfully"
end

# -----------------------------------------------
# CocoaPods Setup
# -----------------------------------------------
# Installs and updates CocoaPods dependencies for the project.
# Uses clean install to ensure fresh dependency resolution.
#
# Usage:
#   setup_shared_cocoapods
def setup_shared_cocoapods
  cocoapods(
    clean_install: true,
    podfile: "./Podfile"
  )
end

# -----------------------------------------------
# Common Export Options
# -----------------------------------------------
# Returns a hash of common export options for app builds.
# Used for local builds with automatic signing.
#
# Parameters:
#   - team_id: Apple Developer Team ID (defaults to MVLT team)
#
# Returns:
#   Hash of export options
#
# Usage:
#   export_options = common_export_options
def common_export_options(team_id = "ZR533W4VLM")
  {
    teamID: team_id,
    uploadBitcode: false,
    uploadSymbols: true,
    signingStyle: "automatic"
  }
end

# -----------------------------------------------
# Environment File Loader
# -----------------------------------------------
# Loads environment variables from a .env file.
# Parses key=value pairs and returns as a hash.
#
# Parameters:
#   - file_path: Path to the .env file
#
# Returns:
#   Hash of environment variables
#
# Usage:
#   env_vars = load_env_file('../config/.env.production')
def load_env_file(file_path)
  env_vars = {}
  if File.exist?(file_path)
    File.foreach(file_path) do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')

      key, value = line.split('=', 2)
      env_vars[key] = value if key && value
    end
  end
  env_vars
end

# -----------------------------------------------
# Dart Define Builder
# -----------------------------------------------
# Builds --dart-define arguments from environment variables.
# Supports both CI (GitHub Secrets) and local (.env file) environments.
#
# CI Environment:
#   Reads from GitHub Secrets with PROD_ prefix:
#   - PROD_SUPABASE_URL
#   - PROD_SUPABASE_ANON_KEY
#   - PROD_ANTHROPIC_API_KEY
#
# Local Environment:
#   Reads from ../config/.env.production file:
#   - SUPABASE_URL
#   - SUPABASE_ANON_KEY
#   - ANTHROPIC_API_KEY
#
# Returns:
#   String of space-separated --dart-define arguments
#
# Usage:
#   dart_defines = build_dart_defines_from_env
def build_dart_defines_from_env
  puts "🔑 Building dart-define arguments for production environment..."

  defines = []

  # In CI, use GitHub Secrets with PROD_ prefix; locally, use .env.production
  if ENV['CI']
    puts "   CI environment detected - using GitHub Secrets"

    # Map GitHub Secrets to dart-define arguments
    # Properly escape values to avoid CocoaPods parsing issues
    defines << "--dart-define=SUPABASE_URL=#{ENV['PROD_SUPABASE_URL']}" if ENV['PROD_SUPABASE_URL']
    defines << "--dart-define=SUPABASE_ANON_KEY=#{ENV['PROD_SUPABASE_ANON_KEY']}" if ENV['PROD_SUPABASE_ANON_KEY']
    defines << "--dart-define=ANTHROPIC_API_KEY=#{ENV['PROD_ANTHROPIC_API_KEY']}" if ENV['PROD_ANTHROPIC_API_KEY']

    puts "   Found #{defines.length} environment variables from GitHub Secrets"
  else
    puts "   Local environment detected - loading from config/.env.production"

    # Load from .env.production for local builds
    env_file_path = '../config/.env.production'
    if File.exist?(env_file_path)
      env_vars = load_env_file(env_file_path)

      defines << "--dart-define=SUPABASE_URL=#{env_vars['SUPABASE_URL']}" if env_vars['SUPABASE_URL']
      defines << "--dart-define=SUPABASE_ANON_KEY=#{env_vars['SUPABASE_ANON_KEY']}" if env_vars['SUPABASE_ANON_KEY']
      defines << "--dart-define=ANTHROPIC_API_KEY=#{env_vars['ANTHROPIC_API_KEY']}" if env_vars['ANTHROPIC_API_KEY']

      puts "   Loaded #{defines.length} environment variables from #{env_file_path}"
    else
      puts "   ⚠️  Warning: #{env_file_path} not found - app may not have access to production APIs"
    end
  end

  # Return as array for better handling, or join with space if needed
  dart_defines = defines.join(' ')
  puts "   Generated dart-define arguments: #{dart_defines.empty? ? '(none)' : 'configured'}"

  dart_defines
end

# -----------------------------------------------
# Flutter CI Preparation
# -----------------------------------------------
# Prepares Flutter for CI builds by cleaning, fetching dependencies,
# and pre-generating platform-specific build files.
#
# Parameters:
#   - dart_defines: String of --dart-define arguments (optional)
#   - platform: Platform to prepare for ("ios" or "macos")
#
# Usage:
#   prepare_shared_flutter_for_ci(dart_defines, "ios")
def prepare_shared_flutter_for_ci(dart_defines = "", platform = "macos")
  puts "🔧 Preparing Flutter for CI build (#{platform})..."

  # Clean and regenerate Flutter files to fix ephemeral issues
  sh("cd .. && flutter clean")
  sh("cd .. && flutter pub get")

  # Pre-generate Flutter build files for the platform
  sh("cd .. && flutter precache --#{platform}")

  # Pass dart-defines to Flutter so it generates the proper config files
  if dart_defines.empty?
    sh("cd .. && flutter build #{platform} --config-only")
  else
    puts "   Including dart-define parameters in Flutter build..."
    sh("cd .. && flutter build #{platform} --config-only #{dart_defines}")
  end

  puts "✅ Flutter prepared for CI build (#{platform})"
end

# -----------------------------------------------
# Keychain Cleanup
# -----------------------------------------------
# Cleans up the CI keychain after build completion or on error.
# Silently ignores errors if keychain doesn't exist.
#
# Usage:
#   cleanup_shared_keychain
def cleanup_shared_keychain
  if ENV['CI']
    begin
      delete_keychain(name: "ci_keychain")
    rescue
      # Ignore keychain cleanup errors
    end
  end
end

# -----------------------------------------------
# Unified Build Number (Deprecated)
# -----------------------------------------------
# NOTE: This function is currently unused but kept for reference.
# It synchronizes build numbers across iOS and macOS platforms.
#
# Parameters:
#   - api_key: App Store Connect API key object
#
# Returns:
#   Integer: Next unified build number
#
# Usage:
#   build_number = get_unified_build_number(api_key)
def get_unified_build_number(api_key)
  puts "🔍 Fetching latest build numbers from TestFlight..."

  ios_build = latest_testflight_build_number(
    api_key: api_key,
    app_identifier: "ai.mvlt.app",
    platform: 'ios',
    initial_build_number: 0
  )

  macos_build = latest_testflight_build_number(
    api_key: api_key,
    app_identifier: "ai.mvlt.app",
    platform: 'osx',
    initial_build_number: 0
  )

  # Return the highest + 1 to keep sequences synchronized
  max_build = [ios_build, macos_build].max
  unified_build = max_build + 1

  puts "📊 Latest builds: iOS=#{ios_build}, macOS=#{macos_build}"
  puts "🔢 Using unified build number: #{unified_build}"

  unified_build
end
