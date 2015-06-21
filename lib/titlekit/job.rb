module Titlekit
  class AbortJob < StandardError
  end

  class Job

    # Returns everything you {Have}
    #
    # @return [Array<Have>] Everything you {Have}
    attr_reader :haves

    # Returns everything you {Want}
    #
    # @return [Array<Want>] Everything you {Want}
    attr_reader :wants

    # Returns the job report, which documents the direct cause of failures
    # and any other unusual events that occur on the job. (regardless if it
    # failed or succeeded)
    #
    # @return [Array<String>] All reported messages
    attr_reader :report

    # Starts a new job.
    #
    # A job requires at least one file you {Have} and one file you {Want}
    # in order to be runable. Use {Job#have} and {Job#want} to add
    # and obtain specification interfaces for the job.
    #
    def initialize
      @haves = []
      @wants = []
      @report = []

      require 'rchardet19'

      begin
        if Gem::Specification.find_by_name('charlock_holmes')
          require 'charlock_holmes'
        end
      rescue Gem::LoadError
      end
    end

    # Runs the job.
    #
    # @return [Boolean] true if the job succeeds, false if it fails.
    #   {Job#report} provides information in case of failure.
    def run
      @wants.each do |want|
        @haves.each do |have|
          import(have)
          retime(have, want)
          cull(have)
          group(have)

          want.subtitles += have.subtitles.clone
        end

        polish(want)
        export(want)
      end

      return true
    rescue AbortJob
      return false
    end

    # Adds a new {Have} specification to your job.
    #
    # @example Using a block without a variable (careful: the scope changes!)
    #   job.have do
    #     encoding('utf-8')
    #     file('path/to/my/input.srt')
    #     fps(25)
    #   end
    #
    # @example Using a block and providing a variable
    #   job.have do |have|
    #     have.encoding('utf-8')
    #     have.file('path/to/my/input.srt')
    #     have.fps(25)
    #   end
    #
    # @example Catching the reference and assigning things at any later point
    #   have = job.have
    #   have.encoding('utf-8')
    #   have.file('path/to/my/input.srt')
    #   have.fps(25)
    #
    # @example Cloning a previous specification and extending on it
    #   have2 = job.have(template: have1)
    #   have2.encoding('ISO-8859-1')
    #   have2.file('path/to/my/input2.srt')
    #
    # @param template [Have] optionally you can specify another {Have} as a
    #   template, from which all properties but the file path are cloned
    # @return [Have] a reference to the newly assigned {Have}
    def have(*_args, template: nil, &block)
      specification = Have.new

      if template
        specification.fps = template.fps.clone
        specification.references = template.references.clone
      end

      if block
        if block.arity < 1
          specification.instance_eval(&block)
        else
          block[specification]
        end
      end

      @haves << specification

      specification
    end

    # Adds a new {Want} specification to your job.
    #
    # @example Using a block without a variable (careful: the scope changes!)
    #   job.want do
    #     encoding('utf-8')
    #     file('path/to/my/output.srt')
    #     fps(23.976)
    #   end
    #
    # @example Using a block and providing a variable
    #   job.want do |want|
    #     want.encoding('utf-8')
    #     want.file('path/to/my/output.srt')
    #     want.fps((23.976)
    #   end
    #
    # @example Catching the reference and assigning things at any later point
    #   want = job.want
    #   want.encoding('utf-8')
    #   want.file('path/to/my/output.srt')
    #   want.fps((23.976)
    #
    # @example Cloning a previous specification and extending on it
    #   want2 = job.want(template: want1)
    #   want2.encoding('ISO-8859-1')
    #   want2.file('path/to/my/output.ass')
    #
    # @param template [Want] optionally you can specify another {Want} as a
    #   template, from which all properties but the file path are cloned
    # @return [Want] a reference to the newly assigned {Want}
    def want(*args, template: nil, &block)
      specification = Want.new

      if template
        specification.fps = template.fps.clone
        specification.references = template.references.clone
      end

      if block
        if block.arity < 1
          specification.instance_eval(&block)
        else
          block[specification]
        end
      end

      @wants << specification

      specification
    end

    private

    # Imports what we {Have}
    #
    # @param [Have] What we {Have}
    def import(have)
      begin
        data = File.read(have.file)
      rescue
        @report << "Failure while reading #{have.file}"
        raise AbortJob
      end

      begin
        if [:detect, :charlock_holmes].include?(have.encoding) && defined?(CharlockHolmes)
          detection = CharlockHolmes::EncodingDetector.detect(data)
          @report << "Assuming #{detection[:encoding]} for #{have.file} (detected by charlock_holmes with #{detection[:confidence]}% confidence)"
          data.force_encoding(detection[:encoding])
        elsif [:detect, :rchardet19].include?(have.encoding) && defined?(CharDet)
          detection = CharDet.detect(data)
          @report << "Assuming #{detection.encoding} for #{have.file} (detected by rchardet19 with #{(detection.confidence * 100).to_i}% confidence)"
          data.force_encoding(detection.encoding)
        else
          @report << "Assuming #{have.encoding} for #{have.file} (user-supplied)"
          data.force_encoding(have.encoding)
        end
      rescue
        @report << "Failure while setting encoding for #{have.file}"
        raise AbortJob
      end

      begin
        data.encode!('UTF-8')
      rescue
        @report << "Failure while transcoding #{have.file} from #{data.encoding} to intermediate UTF-8 encoding"
        raise AbortJob
      end

      begin
        have.subtitles =
          case File.extname(have.file)
          when '.ass'
            ASS.import(data)
          when '.ssa'
            SSA.import(data)
          when '.srt'
            SRT.import(data)
          when '.yt'
            YT.import(data)
          else
            fail 'Not supported'
          end
      rescue
        @report << "Failure while importing #{File.extname(have.file)[1..3].upcase} from #{have.file}"
        raise AbortJob
      end
    end

    # Transfers the subtitles from the state we {Have}, to the state we {Want}.
    #
    # @params have [Have] What we {Have}
    # @params want [Want] What we {Want}
    def retime(have, want)
      matching_references = want.references.keys & have.references.keys

      # Resolve subtitle references by getting actual timecodes
      matching_references.each do |reference|
        if (index = have.references[reference][:subtitle])
          have.references[reference][:timecode] = have.subtitles[index][:start]
        end
      end

      case matching_references.length
      when 3..(_infinity = 1.0 / 0)
        # "synchronization jitter" correction by interpolating ? Consider !
      when  2
        retime_by_double_reference(have,
                                   want,
                                   matching_references[0],
                                   matching_references[1])
      when 1
        if have.fps && want.fps
          retime_by_framerate_plus_reference(have, want, matching_references[0])
        else
          retime_by_single_reference(have, want, matching_references[0])
        end
      when 0
        retime_by_framerate(have, want) if have.fps && want.fps
      end
    end

    # Cleans out subtitles that fell out of the usable time range
    #
    # @params have [Have] What we {Have}
    def cull(have)
      have.subtitles.reject! { |subtitle| subtitle[:end] < 0 }
      have.subtitles.each do |subtitle|
        subtitle[:start] = 0 if subtitle[:start] < 0
      end
    end

    # Assigns track identification fields for distinguishing
    # between continuous/simultaneous subtitles
    #
    # @params have [Have] What we {Have}
    def group(have)
      if have.track
        # Assign a custom track identifier if one was supplied
        have.subtitles.each { |subtitle| subtitle[:track] = have.track }
      elsif @haves.index(have) == 0 || @haves[@haves.index(have) - 1].subtitles.empty?
        # Otherwise let the path be the track identifier for the first subtitle
        have.subtitles.each { |subtitle| subtitle[:track] = have.file }
      else
        # For the 2nd+ subtitles determine the track association by detecting
        # collisions against the previously imported subtitles

        collisions = 0

        have.subtitles.each do |subtitle|
          @haves[@haves.index(have) - 1].subtitles.each do |previous_subtitle|
            collisions += 1 if (subtitle[:start] > previous_subtitle[:start] &&
                                subtitle[:start] < previous_subtitle[:end]) ||
                               (subtitle[:end] > previous_subtitle[:start] &&
                                subtitle[:end] < previous_subtitle[:end]) ||
                               (previous_subtitle[:start] > subtitle[:start] &&
                                previous_subtitle[:start] < subtitle[:end]) ||
                               (previous_subtitle[:end] > subtitle[:start] &&
                                previous_subtitle[:end] < subtitle[:end]) ||
                               (subtitle[:start] == previous_subtitle[:start] ||
                                subtitle[:end] == previous_subtitle[:end])
          end
        end

        if collisions.to_f / have.subtitles.length.to_f > 0.01
          # Add a new track if there are > 1% collisions between these
          # subtitles and the ones that were last imported
          have.subtitles.each { |subtitle| subtitle[:track] = have.file }
        else
          # Otherwise continue using the previous track identifier
          # (= Assume that these and the previous subtitles are one track)
          previous_track = @haves[@haves.index(have) - 1].subtitles.first[:track]
          have.subtitles.each { |subtitle| subtitle[:track] = previous_track }
        end
      end
    end

    # Polishes what we {Want}
    #
    # @params want [Want] What we {Want} polished
    def polish(want)
      # Glue subtitle starts
      want.subtitles.sort_by! { |subtitle| subtitle[:start] }
      want.subtitles.each_cons(2) do |pair|
        distance = pair[1][:start] - pair[0][:start]
        if distance < want.glue_treshold
          pair[0][:start] += distance / 2
          pair[1][:start] -= distance / 2
        end
      end

      # Glue subtitles ends
      want.subtitles.sort_by! { |subtitle| subtitle[:end] }
      want.subtitles.each_cons(2) do |pair|
        if pair[1][:end] - pair[0][:end] < want.glue_treshold
          pair[0][:end] += (pair[1][:end] - pair[0][:end]) / 2
          pair[1][:end] -= (pair[1][:end] - pair[0][:end]) / 2
        end
      end
    end

    # Exports what we {Want}
    #
    # @param want [Want] What we {Want}
    def export(want)
      begin
        data =
          case File.extname(want.file)
          when '.ass'
            ASS.master(want.subtitles)
            ASS.export(want.subtitles)
          when '.ssa'
            SSA.master(want.subtitles)
            SSA.export(want.subtitles)
          when '.srt'
            SRT.master(want.subtitles)
            SRT.export(want.subtitles)
          when '.yt'
            YT.master(want.subtitles)
            YT.export(want.subtitles)
          else
            fail 'Not supported'
          end
      rescue
        @report << "Failure while exporting #{File.extname(want.file)[1..3].upcase} for #{want.file}"
        raise AbortJob
      ensure
        want.subtitles = nil
      end

      if want.encoding
        begin
          data.encode!(want.encoding)
        rescue
          @report << "Failure while transcoding from #{data.encoding} to #{want.encoding} for #{want.file}"
          raise AbortJob
        end
      end

      begin
        IO.write(want.file, data)
      rescue
        @report << "Failure while writing to #{want.file}"
        raise AbortJob
      end
    end

    # Applies a simple timeshift to the subtitle we {Have}.
    # Each subtitle gets shifted forward/backward by the same amount of seconds.
    #
    # @param have [Have] the subtitles we {Have}
    # @param want [Want] the subtitles we {Want}
    # @param reference [Symbol, String] the key of the reference
    def retime_by_single_reference(have, want, reference)
      amount = want.references[reference][:timecode] -
               have.references[reference][:timecode]

      have.subtitles.each do |subtitle|
        subtitle[:start] += amount
        subtitle[:end] += amount
      end
    end

    # Rescales timecodes based on two differing framerates and then applies a
    # simple timeshift to the subtitles we {Have}.
    #
    # @param have [Have] the subtitles we {Have}
    # @param want [Want] the subtitles we {Want}
    # @param reference [Symbol, String] the key of the reference
    def retime_by_framerate_plus_reference(have, want, reference)
      ratio = want.fps.to_f / have.fps.to_f
      have.references[reference][:timecode] *= ratio
      have.subtitles.each do |subtitle|
        subtitle[:start] *= ratio
        subtitle[:end] *= ratio
      end

      amount = want.references[reference][:timecode] -
               have.references[reference][:timecode]

      have.subtitles.each do |subtitle|
        subtitle[:start] += amount
        subtitle[:end] += amount
      end
    end

    # Applies a progressive timeshift on the subtitles we {Have}
    # Two points in time are known for both of which a different shift in time
    # should be applied. Thus a steadily increasing or decreasing forwards or
    # backwards shift will be applied to each subtitle, depending on its
    # place in the time continuum
    #
    # @param have [Have] the subtitles we {Have}
    # @param [Array<Float>] origins the two points in time (given in seconds)
    #   which shall be shifted differently
    # @param [Array<Float>] targets the two amounts of time by which to shift
    #   either of the two points that shall be shifted
    def retime_by_double_reference(have, want, reference_a, reference_b)
      origins = [
        have.references[reference_a][:timecode],
        have.references[reference_b][:timecode]
      ]

      targets = [
        want.references[reference_a][:timecode],
        want.references[reference_b][:timecode]
      ]

      rescale_factor = (targets[1] - targets[0]) / (origins[1] - origins[0])
      rebase_shift = targets[0] - origins[0] * rescale_factor

      have.subtitles.each do |subtitle|
        subtitle[:start] = subtitle[:start] * rescale_factor + rebase_shift
        subtitle[:end] = subtitle[:end] * rescale_factor + rebase_shift
      end
    end

    # Rescales timecodes based on two differing framerates.
    #
    # @param have [Have] the subtitles we {Have}
    # @param want [Want] the subtitles we {Want}
    def retime_by_framerate(have, want)
      ratio = want.fps.to_f / have.fps.to_f
      have.subtitles.each do |subtitle|
        subtitle[:start] *= ratio
        subtitle[:end] *= ratio
      end
    end
  end
end
