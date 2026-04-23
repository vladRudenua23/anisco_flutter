require 'fastlane/action'
require_relative '../helper/anisco_flutter_helper'

module Fastlane
  module Actions
    class AniscoFlutterVersionAction < Action
      def self.run(params)
        pubspec_location = Helper::FlutterVersionHelper.pubspec_location(params)
        _, current_version = Helper::FlutterVersionHelper.load(pubspec_location)
        UI.message("Current version: #{current_version}")
        current_version
      end

      def self.description
        'Get current Flutter version from pubspec.yaml'
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
