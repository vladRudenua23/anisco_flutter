require 'yaml'
require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class FlutterVersionHelper
      REGEX = /^[1-9]\.\d{1,2}\.\d{1,2}\+\d{1,2}$/
      MIN_NUMBERS = [1, 0, 0, 0].freeze
      MAX_MAJOR = 9
      MAX_PART = 99
      PUBSPEC_LOCATION = './pubspec.yaml'

      attr_reader :version_number

      def self.shared_options
        [
          FastlaneCore::ConfigItem.new(
            key: :pubspec_location,
            env_name: 'PUBSPEC_LOCATION',
            description: 'The location of pubspec.yaml',
            optional: true,
            type: String,
            default_value: PUBSPEC_LOCATION
          )
        ]
      end

      def self.pubspec_location(params)
        File.expand_path(params[:pubspec_location] || PUBSPEC_LOCATION)
      end

      def self.read_pubspec(pubspec_location)
        YAML.load_file(pubspec_location)
      rescue StandardError => e
        UI.user_error!("Read pubspec.yaml failed at #{pubspec_location}: #{e.message}")
      end

      def self.fetch_current_version(pubspec)
        current_version = pubspec['version']
        UI.user_error!('Version not found in pubspec.yaml') if current_version.to_s.empty?

        current_version
      end

      def self.load(pubspec_location)
        pubspec = read_pubspec(pubspec_location)
        current_version = fetch_current_version(pubspec)

        [pubspec, current_version]
      end

      def initialize(version_number)
        validate(version_number)
        @version_number = version_number.to_s
      end

      def increment
        numbers = parsed_numbers

        (numbers.length - 1).downto(0) do |index|
          limit = index.zero? ? MAX_MAJOR : MAX_PART

          if numbers[index] < limit
            numbers[index] += 1
            @version_number = format_version(numbers)
            return @version_number
          end

          raise ArgumentError, 'version overflow' if index.zero?

          numbers[index] = 0
        end
      end

      def decrement
        numbers = parsed_numbers
        raise ArgumentError, "can't decrement minimum version" if numbers == MIN_NUMBERS

        (numbers.length - 1).downto(0) do |index|
          minimum = index.zero? ? MIN_NUMBERS[0] : 0
          reset_value = index.zero? ? MIN_NUMBERS[0] : MAX_PART

          if numbers[index] > minimum
            numbers[index] -= 1
            @version_number = format_version(numbers)
            return @version_number
          end

          numbers[index] = reset_value
        end
      end

      def update_pubspec_version(pubspec, pubspec_location)
        pubspec['version'] = @version_number
        File.write(pubspec_location, pubspec.to_yaml)
      end

      private

      def parsed_numbers
        major, minor, patch_with_build = @version_number.split('.', 3)
        patch, build = patch_with_build.split('+', 2)
        [major, minor, patch, build].map(&:to_i)
      end

      def format_version(numbers)
        "#{numbers[0]}.#{numbers[1]}.#{numbers[2]}+#{numbers[3]}"
      end

      def validate(version_number)
        return if REGEX.match?(version_number.to_s)

        raise ArgumentError, 'invalid version number, must be in format X.XX.XX+XX'
      end
    end

    class VariationValidator
      def self.validate(value)
        return if %w[apk ipa appbundle].include?(value.to_s)

        UI.user_error!("Unsupported variation '#{value}'. Allowed values: apk, ipa, appbundle")
      end
    end
  end
end
