require 'treetop'

module Titlekit
  module SRT

    # Internal intermediate class used for parsing with treetop
    class Subtitles < Treetop::Runtime::SyntaxNode
      def build
        elements.map(&:build)
      end
    end

    # Internal intermediate class used for parsing with treetop
    class Subtitle < Treetop::Runtime::SyntaxNode
      def build
        {
          id: id.text_value.to_i,
          start: from.build,
          end: to.build,
          lines: lines.text_value.rstrip
        }
      end
    end

    # Internal intermediate class used for parsing with treetop
    class Timecode < Treetop::Runtime::SyntaxNode
      def build
        value = 0
        value += hours.text_value.to_i * 3600
        value += minutes.text_value.to_i * 60
        value += seconds.text_value.to_i
        value += "0.#{fractions.text_value}".to_f
        value
      end
    end

    # Parses the supplied string and builds the resulting subtitles array.
    #
    # @param string [String] proper UTF-8 SRT file content
    # @return [Array<Hash>] the imported subtitles
    def self.import(string)
      Treetop.load(File.join(__dir__, 'srt'))
      parser = SRTParser.new
      syntax_tree = parser.parse(string)

      if syntax_tree
        return syntax_tree.build
      else
        failure = "failure_index #{parser.failure_index}\n"
        failure += "failure_line #{parser.failure_line}\n"
        failure += "failure_column #{parser.failure_column}\n"
        failure += "failure_reason #{parser.failure_reason}\n"

        fail failure
      end
    end

    # Master the subtitles for best possible usage of the format's features.
    #
    # @param subtitles [Array<Hash>] the subtitles to master
    def self.master(subtitles)
      tracks = subtitles.map { |subtitle| subtitle[:track] }.uniq

      if tracks.length == 1

        # maybe styling? aside that: nothing more!

      elsif tracks.length >= 2

        mastered_subtitles = []

        # Determine timeframes with a discrete state
        cuts = subtitles.map { |s| [s[:start], s[:end]] }.flatten.uniq.sort
        frames = []
        cuts.each_cons(2) do |pair|
          frames << { start: pair[0], end: pair[1] }
        end

        frames.each do |frame|
          intersecting = subtitles.select do |subtitle|
            (subtitle[:end] == frame[:end] || subtitle[:start] == frame[:start] ||
            (subtitle[:start] < frame[:start] && subtitle[:end] > frame[:end]))
          end

          if intersecting.any?
            intersecting.sort_by! { |subtitle| tracks.index(subtitle[:track]) }

            subtitle = {}
            subtitle[:id] = mastered_subtitles.length + 1
            subtitle[:start] = frame[:start]
            subtitle[:end] = frame[:end]

            # Combine two or more than three simultaneous tracks by
            # stacking them directly, with different colors.

            colored_lines = intersecting.map do |subtitle|
              color = DEFAULT_PALETTE[tracks.index(subtitle[:track]) % DEFAULT_PALETTE.length]
              "<font color=\"##{color}\">#{subtitle[:lines]}</font>"
            end

            subtitle[:lines] = colored_lines.join("\n")

            mastered_subtitles << subtitle
          end
        end

        subtitles.replace(mastered_subtitles)
      end
    end

    # Exports the supplied subtitles to SRT format
    #
    # @param subtitles [Array<Hash>] The subtitle to export
    # @return [String] Proper UTF-8 SRT as a string
    def self.export(subtitles)
      result = ''

      subtitles.each_with_index do |subtitle, index|
        result << (index + 1).to_s
        result << "\n"
        result << SRT.build_timecode(subtitle[:start])
        result << ' --> '
        result << SRT.build_timecode(subtitle[:end])
        result << "\n"
        result << subtitle[:lines]
        result << "\n\n"
      end

      result
    end

    protected

    # Builds an SRT-formatted timecode from a float representing seconds
    #
    # @param seconds [Float] an amount of seconds
    # @return [String] An SRT-formatted timecode ('hh:mm:ss,ms')
    def self.build_timecode(seconds)
      format('%02d:%02d:%02d,%s',
             seconds / 3600,
             (seconds % 3600) / 60,
             seconds % 60,
             format('%.3f', seconds)[-3, 3])
    end

    # Parses an SRT-formatted timecode into a float representing seconds
    #
    # @param timecode [String] An SRT-formatted timecode ('hh:mm:ss,ms')
    # @param [Float] an amount of seconds
    def self.parse_timecode(timecode)
      mres = timecode.match(/(?<h>\d+):(?<m>\d+):(?<s>\d+),(?<ms>\d+)/)
      "#{mres['h'].to_i * 3600 + mres['m'].to_i * 60 + mres['s'].to_i}.#{mres['ms']}".to_f
    end
  end
end
