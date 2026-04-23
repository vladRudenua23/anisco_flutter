require 'fastlane/action'
require_relative '../helper/anisco_flutter_helper'

module Fastlane
  module Actions
    class AniscoFlutterIncrementVersionAction < Action
      def self.run(params)
        pubspec_location = Helper::FlutterVersionHelper.pubspec_location(params)
        pubspec, current_version = Helper::FlutterVersionHelper.load(pubspec_location)

        UI.message("Current version: #{current_version}")

        version = Helper::FlutterVersionHelper.new(current_version)
        next_version = version.increment
        version.update_pubspec_version(pubspec, pubspec_location)

        UI.success("Version updated: #{current_version} -> #{next_version}")
        next_version
      end

      def self.description
        'Increment Flutter version in pubspec.yaml using 99-based rollover rules'
      end

      def self.authors
        ['rudenua.dev@gmail.com']
      end

      def self.available_options
        Helper::FlutterVersionHelper.shared_options
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
