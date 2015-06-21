module Titlekit
  class Specification

    # Only for internal usage by the job
    attr_accessor :subtitles

    def initialize
      @encoding = nil
      @file = nil
      @fps = nil
      @references = {}
      @subtitles = []
      @track = nil

      self
    end

    # Specifies the encoding you have or want.
    #
    # @param [String] A string specifying the encoding, e.g. 'utf-8' or 'ISO-8859-1'
    # @return If you omit the argument, it returns the already specified encoding
    def encoding(*args)
      if args.empty?
        return @encoding
      else
        @encoding = args[0]
        return self
      end
    end

    # Specifies the file (path) you have or want.
    #
    # @param [String] A string specifying the path to the file
    # @return If you omit the argument, it returns the already specified path
    def file(*args)
      if args.empty?
        return @file
      else
        @file = args[0]
        return self
      end
    end

    # Specifies the track the subtitles should be assigned to.
    #
    # @param [String] A string specifying the track identifier
    # @return If you omit the argument, it returns the already specified track
    def track(*args)
      if args.empty?
        return @track
      else
        @track = args[0]
        return self
      end
    end

    # Specifies the framerate you have or want.
    #
    # @param [Float] A float specifying the frames per second, e.g. 23.976
    # @return If you omit the argument, it returns the already specified fps
    def fps(*args)
      if args.empty?
        return @fps
      else
        @fps = args[0]
        return self
      end
    end

    # Returns all named references you have specified
    def references
      @references
    end

    # Places a named reference (in the form of a string or a symbol)
    # on a timecode specified by either +hours+, +minutes+, +seconds+
    # or +milliseconds+.
    #
    # Its typical use-case is to reference a specific subtitle you can
    # recognize in both the movie and your subtitle file, where usually
    # for the subtitle file (represented by {Have}) you will reference
    # the subtitle index and for the movie (represented by {Want}) you
    # will reference the timecode that is displayed when the line occurs
    # in the movie.
    #
    # @example Referencing a timecode by hours
    #   have.reference('Earl grey, hot', hours: 0.963)
    #
    # @example Referencing a timecode by seconds
    #   have.reference('In a galaxy ...', seconds: 14.2)
    #
    # @example Referencing a timecode by an SRT-style timecode
    #   have.reference('In a galaxy ...', srt_timecode: '00:00:14,200')
    #
    # @example Referencing a timecode by an ASS-style timecode
    #   have.reference('In a galaxy ...', ass_timecode: '0:00:14,20')
    #
    # @example Referencing a timecode by an SSA-style timecode
    #   have.reference('In a galaxy ...', ssa_timecode: '0:00:14,20')
    #
    # @example Symbols can be used as references as well!
    #   have.reference(:narrator_begins, minutes: 9.6)
    #
    # @param name [String, Symbol] The name of the reference
    # @param hours [Float]
    # @param minutes [Float]
    # @param seconds [Float]
    # @param milliseconds [Float]
    def reference(name,
                  *_args,
                  hours: nil,
                  minutes: nil,
                  seconds: nil,
                  milliseconds: nil,
                  srt_timecode: nil,
                  ssa_timecode: nil,
                  ass_timecode: nil)

      @references[name] =
        case
        when hours
          { timecode: hours * 3600 }
        when minutes
          { timecode: minutes * 60 }
        when seconds
          { timecode: seconds }
        when milliseconds
          { timecode: milliseconds / 1000 }
        when srt_timecode
          { timecode: Titlekit::SRT.parse_timecode(srt_timecode) }
        when ssa_timecode
          { timecode: Titlekit::SSA.parse_timecode(ssa_timecode) }
        when ass_timecode
          { timecode: Titlekit::ASS.parse_timecode(ass_timecode) }
        end

      self
    end
  end
end
