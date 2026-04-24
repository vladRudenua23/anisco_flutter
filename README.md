# anisco_flutter plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-anisco_flutter)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin.
To add `fastlane-plugin-anisco_flutter` to your project, run:

```bash
fastlane add_plugin anisco_flutter
```

## About anisco_flutter

`anisco_flutter` provides five actions:

- `anisco_flutter_prepare_build`
- `anisco_flutter_build`
- `anisco_flutter_version`
- `anisco_flutter_increment_version`
- `anisco_flutter_decrement_version`

The plugin is intended for small Flutter build pipelines:

- prepare the project before build
- build `apk`, `ipa`, or `appbundle`
- read the current version from `pubspec.yaml`
- increment or decrement the version using the plugin version rules

## Action: anisco_flutter_prepare_build

Runs a standard prepare sequence:

1. `flutter clean`
2. `flutter pub get`
3. optionally `build_runner`
4. optionally `spider build`
5. optionally extra shell commands

Parameters:

- `use_spider` optional, `true` or `false`, default `false`
- `spider_custom_path` optional, `String`, custom path passed to `spider -p ... build`
- `use_build_runner` optional, `true` or `false`, default `false`
- `use_fvm` optional, `true` or `false`, default `false`
- `extra_commands` optional, `Array`, additional shell commands, default `[]`

Example:

```ruby
anisco_flutter_prepare_build(
  use_spider: true,
  spider_custom_path: './lib/resources',
  use_build_runner: true,
  use_fvm: true,
  extra_commands: ['melos bootstrap']
)
```

Minimal example:

```ruby
anisco_flutter_prepare_build()
```

## Action: anisco_flutter_build

Builds a Flutter artifact.

Parameters:

- `variation` required, one of: `apk`, `ipa`, `appbundle`
- `flavor` optional, `String`
- `use_fvm` optional, `true` or `false`, default `false`
- `dart_defines` optional, `Hash`, default `{}`
- `main_file_path` optional, `String`
- `obfuscate_path` optional, `String`
- `export_method` optional, `String`, supported only on iOS
- `no_codesign` optional, value presence enables `--no-codesign`, supported only on iOS

Example with all fields:

```ruby
anisco_flutter_build(
  variation: 'ipa',
  flavor: 'prod',
  use_fvm: true,
  dart_defines: {
    'ENV_FILE_PATH' => 'env/.env-prod',
    'SENTRY_ENABLED' => 'true'
  },
  main_file_path: 'lib/main_prod.dart',
  obfuscate_path: './build/debug-info',
  export_method: 'ad-hoc',
  no_codesign: 'true'
)
```

Android example:

```ruby
anisco_flutter_build(
  variation: 'apk',
  flavor: 'dev',
  use_fvm: true,
  dart_defines: {
    'ENV_FILE_PATH' => 'env/.env-dev'
  },
  main_file_path: 'lib/main_dev.dart'
)
```

Minimal example:

```ruby
anisco_flutter_build(
  variation: 'appbundle'
)
```

## Action: anisco_flutter_version

Returns the current version from `pubspec.yaml`.

Parameters:

- `pubspec_location` optional, `String`, default `./pubspec.yaml`

Example:

```ruby
version = anisco_flutter_version(
  pubspec_location: './pubspec.yaml'
)
```

## Action: anisco_flutter_increment_version

Reads the current version from `pubspec.yaml`, increments it, writes it
back, and returns the new value.

Parameters:

- `pubspec_location` optional, `String`, default `./pubspec.yaml`

Example:

```ruby
next_version = anisco_flutter_increment_version(
  pubspec_location: './pubspec.yaml'
)
```

## Action: anisco_flutter_decrement_version

Reads the current version from `pubspec.yaml`, decrements it, writes it
back, and returns the new value.

Parameters:

- `pubspec_location` optional, `String`, default `./pubspec.yaml`

Example:

```ruby
previous_version = anisco_flutter_decrement_version(
  pubspec_location: './pubspec.yaml'
)
```

## Version Format

The plugin expects versions in this format:

```text
X.XX.XX+XX
```

Examples:

- `1.0.0+0`
- `1.12.34+56`
- `9.99.99+99`

Rules:

- major version: `1..9`
- minor version: `0..99`
- patch version: `0..99`
- build number: `0..99`

The formatted output always looks like:

```text
major.minor.patch+build
```

Increment examples:

- `1.0.0+0` -> `1.0.0+1`
- `1.0.0+99` -> `1.0.1+0`
- `1.0.99+99` -> `1.1.0+0`
- `1.99.99+99` -> `2.0.0+0`

Decrement examples:

- `1.0.0+1` -> `1.0.0+0`
- `1.0.1+0` -> `1.0.0+99`
- `1.1.0+0` -> `1.0.99+99`

Minimum version:

- `1.0.0+0`

Maximum version:

- `9.99.99+99`

## Fastfile Example

```ruby
platform :android do
  lane :build_release do |options|
    flavor = options[:flavor] || 'dev'

    anisco_flutter_prepare_build(
      use_build_runner: true,
      use_fvm: true
    )

    version = anisco_flutter_increment_version()

    anisco_flutter_build(
      variation: 'apk',
      flavor: flavor,
      use_fvm: true,
      dart_defines: {
        'APP_VERSION' => version
      }
    )
  end
end
```

## Validation Notes

- `variation` must be `apk`, `ipa`, or `appbundle`
- `export_method` works only on iOS lanes
- `no_codesign` works only on iOS lanes
- `pubspec.yaml` must contain a valid `version:` line
- version must match `X.XX.XX+XX`
- increment above `9.99.99+99` is rejected
- decrement below `1.0.0+0` is rejected

## Local Development

Install dependencies:

```bash
bundle install
```

Run tests:

```bash
bundle exec rspec
```

Run the full plugin checks:

```bash
rake
```

Auto-fix some style issues:

```bash
rubocop -a
```

## Troubleshooting

If build fails:

- verify `variation`
- verify the current lane platform for iOS-only options
- verify `flutter` or `fvm flutter` is available
- verify `main_file_path` exists if provided

If version actions fail:

- verify `pubspec_location`
- verify `pubspec.yaml` contains `version: X.XX.XX+XX`
- verify the current version is inside the supported range

If you have trouble using fastlane plugins, see the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## About fastlane

[_fastlane_](https://fastlane.tools) is a tool for automating mobile build and release workflows.
