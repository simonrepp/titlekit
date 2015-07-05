require 'treetop'

module Titlekit
  module ASS

    # Internal intermediate class used for parsing with treetop
    class Subtitles < Treetop::Runtime::SyntaxNode
      def build
        event_section.events.build
      end
    end

    # Internal intermediate class used for parsing with treetop
    class ScriptInfo < Treetop::Runtime::SyntaxNode
      def build
        # elements.map { |subtitle| subtitle.build }
      end
    end

    # Internal intermediate class used for parsing with treetop
    class V4PStyles < Treetop::Runtime::SyntaxNode
      def build
        # elements.map { |subtitle| subtitle.build }
      end
    end

    # Internal intermediate class used for parsing with treetop
    class Events < Treetop::Runtime::SyntaxNode
      def build
        elements.map do |line|
          subtitle = {}

          fields = line.text_value.split(',')

          subtitle[:id] = elements.index(line) + 1
          subtitle[:start] = SSA.parse_timecode(fields[1])
          subtitle[:end] = SSA.parse_timecode(fields[2])
          subtitle[:lines] = fields[9..-1].join.gsub('\N', "\n")

          subtitle
        end
      end
    end

    # Parses the supplied string and builds the resulting subtitles array.
    #
    # @param string [String] proper UTF-8 ASS file content
    # @return [Array<Hash>] the imported subtitles
    def self.import(string)
      Treetop.load(File.join(__dir__, 'ass'))
      parser = ASSParser.new
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

      elsif tracks.length == 2 || tracks.length == 3

        subtitles.each do |subtitle|
          case tracks.index(subtitle[:track])
          when 0
            subtitle[:style] = 'Default'
          when 1
            subtitle[:style] = 'Top'
          when 2
            subtitle[:style] = 'Middle'
          end
        end

      elsif tracks.length >= 4

        mastered_subtitles = []

        # Determine timeframes with a discrete state
        cuts = subtitles.map { |s| [s[:start], s[:end]] }.flatten.uniq.sort
        frames = []
        cuts.each_cons(2) do |pair|
          frames << { start: pair[0], end: pair[1] }
        end

        frames.each do |frame|
          intersecting = subtitles.select do |subtitle|
            subtitle[:end] == frame[:end] ||
            subtitle[:start] == frame[:start] ||
            (subtitle[:start] < frame[:start] && subtitle[:end] > frame[:end])
          end

          if intersecting.any?
            intersecting.sort_by! { |subtitle| tracks.index(subtitle[:track]) }
            intersecting.each do |subtitle|
              color = tracks.index(subtitle[:track]) % DEFAULT_PALETTE.length

              new_subtitle = {
                id: mastered_subtitles.length + 1,
                start: frame[:start],
                end: frame[:end],
                style: DEFAULT_PALETTE[color],
                lines: subtitle[:lines]
              }

              mastered_subtitles << new_subtitle
            end
          end
        end

        subtitles.replace(mastered_subtitles)
      end
    end

    # Exports the supplied subtitles to ASS format
    #
    # @param subtitles [Array<Hash>] The subtitle to export
    # @return [String] Proper UTF-8 ASS as a string
    def self.export(subtitles)
      result = ''

      result << "[Script Info]\nScriptType: v4.00+\n\n"
      result << "[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\n"
      result << "Style: Default,Arial,16,&H00FFFFFF,&H00FFFFFF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1\n"
      result << "Style: Top,Arial,16,&H00FFFFFF,&H00FFFFFF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,8,20,20,20,1\n"
      result << "Style: Middle,Arial,16,&H00FFFFFF,&H00FFFFFF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,5,20,20,20,1\n"

      DEFAULT_PALETTE.each do |color|
        processed_color = '&H00' + (color[4..5] + color[2..3] + color[0..1])
        result << "Style: #{color},Arial,16,#{processed_color},#{processed_color},&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1\n"
      end

      result << "\n" # Close styles section

      result << "[Events]\nFormat: Layer, Start, End, Style, Actor, MarginL, MarginR, MarginV, Effect, Text\n"

      subtitles.each do |subtitle|
        fields = [
          'Dialogue: 0',  # Format: Marked
          SSA.build_timecode(subtitle[:start]),  # Start
          SSA.build_timecode(subtitle[:end]),  # End
          subtitle[:style] || 'Default',  # Style
          '',  # Name
          '0000',  # MarginL
          '0000',  # MarginR
          '0000',  # MarginV
          '', # Effect
          subtitle[:lines].gsub("\n", '\N')  # Text
        ]

        result << fields.join(',') + "\n"
      end

      result
    end

    protected

    # Builds an ASS-formatted timecode from a float representing seconds
    #
    # @param seconds [Float] an amount of seconds
    # @return [String] An ASS-formatted timecode ('h:mm:ss.ms')
    def self.build_timecode(seconds)
      format('%01d:%02d:%02d.%s',
             seconds / 3600,
             (seconds % 3600) / 60,
             seconds % 60,
             format('%.2f', seconds)[-2, 3])
    end

    # Parses an ASS-formatted timecode into a float representing seconds
    #
    # @param timecode [String] An ASS-formatted timecode ('h:mm:ss.ms')
    # @param [Float] an amount of seconds
    def self.parse_timecode(timecode)
      m = timecode.match(/(?<h>\d):(?<m>\d{2}):(?<s>\d{2})[:|\.](?<ms>\d+)/)
      m['h'].to_i * 3600 + m['m'].to_i * 60 + m['s'].to_i + "0.#{m['ms']}".to_f
    end
  end
end
