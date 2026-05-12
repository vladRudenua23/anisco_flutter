require 'yaml'
require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class FlutterVersionHelper
      # Captures major.minor.patch+build; same pattern as validation.
      SEGMENT_REGEX = /^(\d+)\.(\d+)\.(\d+)\+(\d+)$/
      VERSION_LINE_REGEX = /^version:\s*.+$/
      MIN_SEMVER = [1, 0, 0, 0].freeze
      # Max value for major, minor, patch, and build (each 0..999).
      MAX_SEGMENT = 999
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
        s = version_number.to_s
        @version_number = s
        m = s.match(SEGMENT_REGEX)
        @w_maj, @w_min, @w_pat, @w_bld = m.captures.map(&:length)
      end

      # Increments build first (..+N). Build max 999 → patch +1, build 0.
      # Patch max 999 → minor +1, patch 0, build 0. Same limit 999 for major/minor.
      def increment
        mjr, mnr, ptch, bld = parsed_numbers

        if bld < MAX_SEGMENT
          bld += 1
        elsif ptch < MAX_SEGMENT
          @w_bld = 1
          bld = 0
          ptch += 1
        elsif mnr < MAX_SEGMENT
          @w_bld = 1
          bld = 0
          ptch = 0
          mnr += 1
          @w_pat = 1
        elsif mjr < MAX_SEGMENT
          @w_bld = 1
          bld = 0
          ptch = 0
          mnr = 0
          mjr += 1
          @w_min = 1
          @w_pat = 1
        else
          raise ArgumentError, 'version overflow'
        end

        format_version([mjr, mnr, ptch, bld])
      end

      def decrement
        mjr, mnr, ptch, bld = parsed_numbers
        if [mjr, mnr, ptch, bld] == MIN_SEMVER
          raise ArgumentError, "can't decrement minimum version"
        end

        if bld.positive?
          bld -= 1
        elsif ptch.positive?
          bld = MAX_SEGMENT
          ptch -= 1
        elsif mnr.positive?
          bld = MAX_SEGMENT
          ptch = MAX_SEGMENT
          mnr -= 1
        elsif mjr > MIN_SEMVER[0]
          bld = MAX_SEGMENT
          ptch = MAX_SEGMENT
          mnr = MAX_SEGMENT
          mjr -= 1
        else
          raise ArgumentError, "can't decrement minimum version"
        end

        format_version([mjr, mnr, ptch, bld])
      end

      def update_pubspec_version(_pubspec, pubspec_location)
        pubspec_content = File.read(pubspec_location)
        updated_content = pubspec_content.sub(
          VERSION_LINE_REGEX,
          "version: #{@version_number}"
        )

        if updated_content == pubspec_content
          UI.user_error!("Version line not found in pubspec.yaml at #{pubspec_location}")
        end

        File.write(pubspec_location, updated_content)
      end

      private

      def parsed_numbers
        major, minor, patch_with_build = @version_number.split('.', 3)
        patch, build = patch_with_build.split('+', 2)
        [major, minor, patch, build].map(&:to_i)
      end

      def format_version(nums)
        mjr, mnr, ptch, bld = nums
        @w_maj = [@w_maj, mjr.to_s.length].max
        @w_min = [@w_min, mnr.to_s.length].max
        @w_pat = [@w_pat, ptch.to_s.length].max
        @w_bld = [@w_bld, bld.to_s.length].max
        @version_number =
          "#{mjr.to_s.rjust(@w_maj, '0')}." \
          "#{mnr.to_s.rjust(@w_min, '0')}." \
          "#{ptch.to_s.rjust(@w_pat, '0')}+" \
          "#{bld.to_s.rjust(@w_bld, '0')}"
        @version_number
      end

      def validate(version_number)
        return if SEGMENT_REGEX.match?(version_number.to_s)

        raise ArgumentError,
              'invalid version number, must be in format X.Y.Z+build (integers)'
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
