require 'fastlane/action'
require 'bundler'
require_relative '../helper/anisco_flutter_helper'

module Fastlane
  module Actions
    class AniscoFlutterBuildAction < Action
      def self.run(params)
        platform = Actions.lane_context[SharedValues::PLATFORM_NAME].to_s
        flavor = params[:flavor]
        variation = params[:variation]
        use_fvm = params[:use_fvm] || false
        main_file_path = params[:main_file_path]
        obfuscate_path = params[:obfuscate_path]
        export_method = params[:export_method]
        no_codesign = params[:no_codesign]
        dart_defines = params[:dart_defines] || {}

        UI.user_error!('export_method is supported only for ios') if export_method && platform != 'ios'
        UI.user_error!('no_codesign is supported only for ios') if no_codesign && platform != 'ios'

        flutter_command = use_fvm ? 'fvm flutter' : 'flutter'
        command = [flutter_command, 'build', variation.to_s]
        command += ['--flavor', flavor] if flavor
        command += ['-t', main_file_path] if main_file_path

        dart_defines.each do |key, value|
          command << "--dart-define=#{key}=#{value}"
        end

        command << "--export-method=#{export_method}" if export_method
        command << '--no-tree-shake-icons'

        if obfuscate_path
          command << '--obfuscate'
          command << "--split-debug-info=#{obfuscate_path}"
        end

        command << '--no-codesign' if no_codesign

        Bundler.with_unbundled_env do
          Actions.sh(command.join(' '))
        end
      end

      def self.description
        'Build Flutter artifact'
      end

      def self.authors
        ['rudenua.dev@gmail.com']
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :variation,
            description: 'Build variation: apk, ipa, appbundle',
            optional: false,
            verify_block: proc do |value|
              Helper::VariationValidator.validate(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :flavor,
            description: 'Flutter flavor',
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :use_fvm,
            description: 'Use fvm flutter instead of flutter',
            optional: true,
            type: Boolean,
            default_value: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :dart_defines,
            description: 'Dart defines hash',
            optional: true,
            type: Hash,
            default_value: {}
          ),
          FastlaneCore::ConfigItem.new(
            key: :main_file_path,
            description: 'Path to main file',
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :obfuscate_path,
            description: 'Path to obfuscate folder',
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :export_method,
            description: 'Only for ios',
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :no_codesign,
            description: 'Only for ios',
            optional: true,
            type: String
          )
        ]
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
