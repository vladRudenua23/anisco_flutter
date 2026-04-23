# anisco_flutter plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-anisco_flutter)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-anisco_flutter`, add it to your project by running:

```bash
fastlane add_plugin anisco_flutter
```

## About anisco_flutter

Fastlane plugin with reusable Flutter actions for preparing builds, building artifacts, and reading or updating the version in `pubspec.yaml`.

Included actions:
- `anisco_flutter_prepare_build`
- `anisco_flutter_build`
- `anisco_flutter_version`
- `anisco_flutter_increment_version`
- `anisco_flutter_decrement_version`

## Example

Prepare a Flutter project before build:

```ruby
anisco_flutter_prepare_build(
  use_fvm: true,
  use_build_runner: true
)
```

Build APK:

```ruby
anisco_flutter_build(
  variation: 'apk',
  flavor: 'dev',
  use_fvm: true,
  dart_defines: {
    'ENV_FILE_PATH' => 'env/.env-dev'
  }
)
```

Read current version:

```ruby
version = anisco_flutter_version(
  pubspec_location: './pubspec.yaml'
)
```

Increment version:

```ruby
next_version = anisco_flutter_increment_version(
  pubspec_location: './pubspec.yaml'
)
```

Decrement version:

```ruby
previous_version = anisco_flutter_decrement_version(
  pubspec_location: './pubspec.yaml'
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
