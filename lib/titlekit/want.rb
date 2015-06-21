module Titlekit
  class Want < Specification

    def initialize
      super
      @glue_treshold = 0.3
    end

    # For dual+ subtitles the starts and ends of simultaneously occuring
    # subtitles can be micro-adjusted together if their distance is smaller
    # than the glue_treshold. Normally defaults to 0.3
    #
    # @param [Float] Specifies the new glue_treshold
    # @return If you omit the argument, it returns the set glue_treshold
    def glue_treshold(*args)
      if args.empty?
        return @glue_treshold
      else
        @glue_treshold = args[0]
        return self
      end
    end
  end
end
