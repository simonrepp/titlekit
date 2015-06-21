module Titlekit

  # Specifies existing input for a job.
  class Have < Specification

    def initialize
      super

      @encoding = :detect
    end

    # @param [String, Symbol] A string specifying the encoding if it is known,
    #   (e.g. 'UTF-8', 'ISO-8859-1'), :detect in case you don't know, and
    #   :rchardet19 or :charlock_holmes if you have installed an additional
    #   detection library and want to specifically use one or the other.
    #
    # @return If you omit the argument it returns the already specified encoding
    def encoding(*args)
      if args.empty?
        return @encoding
      else
        @encoding = args[0]
        return self
      end
    end

    # Places a named reference (in the form of a string or a symbol) on
    # either a +subtitle+ index or a timecode specified by either
    # +hours+, +minutes+, +seconds+ or +milliseconds+.
    #
    # Its typical use-case is to reference a specific subtitle you can
    # recognize in both the movie and your subtitle file, where usually
    # for the subtitle file (represented by {Have}) you will reference
    # the subtitle index and for the movie (represented by {Want}) you
    # will reference the timecode that is displayed when the line occurs
    # in the movie.
    #
    # @example Referencing a subtitle index (ZERO-INDEXED! First subtitle is 0)
    #   have.reference('Earl grey, hot', subtitle: 645)
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
    #   have.reference(:narrator_begins, minutes: 7.9)
    #
    # @param name [String, Symbol] The name of the reference
    # @param subtitle [Integer] Heads up: Numbering starts at 1!
    # @param hours [Float]
    # @param minutes [Float]
    # @param seconds [Float]
    # @param milliseconds [Float]
    def reference(name,
                  *_args,
                  subtitle: nil,
                  hours: nil,
                  minutes: nil,
                  seconds: nil,
                  milliseconds: nil,
                  srt_timecode: nil,
                  ssa_timecode: nil,
                  ass_timecode: nil)

      if subtitle
        @references[name] = { subtitle: subtitle }
      else
        super(name,
              hours: hours,
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
              srt_timecode: srt_timecode,
              ssa_timecode: ssa_timecode,
              ass_timecode: ass_timecode)
      end

      self
    end
  end
end
