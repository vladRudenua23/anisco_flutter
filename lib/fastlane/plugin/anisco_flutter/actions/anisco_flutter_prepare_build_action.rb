require 'fastlane/action'
require 'bundler'

module Fastlane
  module Actions
    class AniscoFlutterPrepareBuildAction < Action
      def self.run(params)
        use_spider = params[:use_spider] || false
        spider_custom_path = params[:spider_custom_path]
        use_build_runner = params[:use_build_runner] || false
        use_fvm = params[:use_fvm] || false
        extra_commands = params[:extra_commands] || []
        flutter_command = use_fvm ? 'fvm flutter' : 'flutter'
        dart_command = use_fvm ? 'fvm dart' : 'dart'
        commands = []
        commands << "#{flutter_command} clean"
        commands << "#{flutter_command} pub get"
        commands << "#{dart_command} run build_runner build --delete-conflicting-outputs" if use_build_runner

        if use_spider
          if spider_custom_path
            commands << "spider -p #{spider_custom_path} build"
          else
            commands << 'spider build'
          end
        end

        commands.concat(extra_commands)

        commands.each do |command|
          Bundler.with_unbundled_env do
            Actions.sh(command)
          end
        end
      end

      def self.description
        'Prepare Flutter project for build by running clean, pub get, generators and spider'
      end

      def self.authors
        ['rudenua.dev@gmail.com']
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :use_spider,
            description: 'Run spider build',
            optional: true,
            type: Boolean,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :spider_custom_path,
            description: 'Custom path for spider command',
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :use_build_runner,
            description: 'Run build_runner build with delete conflicting outputs',
            optional: true,
            type: Boolean,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :use_fvm,
            description: 'Use fvm flutter and fvm dart',
            optional: true,
            type: Boolean,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :extra_commands,
            description: 'Additional shell commands to run after default prepare steps',
            optional: true,
            type: Array,
            default_value: []
          )
        ]
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
