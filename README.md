# Titlekit [![Build Status](https://travis-ci.org/simonrepp/titlekit.png)](https://travis-ci.org/simonrepp/titlekit)

Featureful Ruby library for SRT / ASS / SSA subtitles

*Titlekit supports SRT, ASS and SSA, file format conversion, transcoding, automatic encoding detection, creation of simultaneous/multi-language subtitles, and timecode corrections with simple, progressive and framerate-based approaches. All of this is packed into a natural, dead-simple (and also irb-friendly) API.*

## Installation

Add the `titlekit` gem to your gemfile or install it yourself:

     $ gem install titlekit
     
### Optional installation recommendation

Titlekit uses [rchardet19](https://github.com/oleander/rchardet) to detect unknown encodings; There is another library for this task called [charlock_holmes](https://github.com/brianmario/charlock_holmes), which offers more robust detection algorithms, but is not included by default because it relies on external C libraries that can make its installation anywhere from semi-easy to impossible. If you want Titlekit to use *charlock_holmes*, install it yourself, and Titlekit will automatically use it over *rchardet19*!

## Documentation

### Basic example

A small hello world of Titlekit: **Converting from .srt to .ssa format**

```ruby
  job = Titlekit::Job.new             # (1) Initialize
  job.have { file('existing.srt') }   # (2) Specify what you have
  job.want { file('converted.ssa') }  # (3) Specify what you want
  job.run                             # (4) Make it happen
```
### Checking success

The return value from `#run` will tell you if the job was a success. If it was not,
you can access `#report` to get messages related to the direct failure cause and also on
anything suspicious that might have happened before (e.g. Low confidence when detecting an
unknown encoding)

```ruby
  if job.run
    # hooray
  else
    puts job.report.join("\n")
  end
```

### Commandline Template Generator

To get you started quickly with edit scripts for subtitles, you can use a console command provided by Titlekit:

     $ titlekit templates

If there are no subtitle files present in your current directory, this will generate a file called `process_generic.rb`, if there are subtitle files present, it will generate a file called `process_[your-subtitle-filename].rb` for each subtitle file that was found. In either case all of these files will contain a basic but complete scaffolding script for processing your subtitle file with Titlekit. In the case of the non-generic templates, they will already contain the correct filename for the input file. Together with some concise in-line comments, these templates are meant to help you quickly start off with your task.

### All features by example

In all following examples I will omit `(1)` and `(4)` from the basic example, because they stay the same.  
All the functionalities from all the following examples can be combined in any way you want.

#### Transcoding

```ruby
  job.have do
    file('input.srt')
    encoding('ISO-8859-1')
  end
  
  job.want do
    file('output.srt')
    encoding('UTF-8')
  end
```

#### Converting

```ruby
  job.have { file('input.ass') }
  job.want { file('output.srt') }
```

#### Simple timeshifting

```ruby
  job.have do
    file('input.srt')
    reference('first sentence spoken', subtitle: 0)
  end
  
  job.want do
    file('output.srt')
    reference('first sentence spoken', srt_timecode: '00:00:54,200')
  end
```

#### Progressive timeshifting

```ruby
  job.have do
    file('input.srt')
    reference('first subtitle', subtitle: 0)
    reference('last subtitle', subtitle: 475)
  end
  
  job.want do
    file('output.srt')
    reference('first subtitle', minutes: 3.76)
    reference('last subtitle', hours: 1.8912)
  end
```

#### Framerate-based timeshifting

```ruby
  job.have do
    file('input.srt')
    fps(25)
  end
  
  job.want do
    file('output.srt')
    fps(23.976)
  end
```

#### Mixed mode timeshifting

```ruby
  job.have do
    file('input.srt')
    fps(25)
    reference(:first_sub, subtitle: 0)
  end
  
  job.want do
    file('output.srt')
    fps(23.976)
    reference(:first_sub, minute: 13.49)    
  end
```

#### Merging

Subtitles that don't overlap are automatically merged and treated as one track.

```ruby
  job.have do
    file('subs_chapter1.srt')
  end

  job.have do
    file('subs_chapter2.srt')
  end

  job.want do
    file('subs_both_chapters_combined.srt')
  end
```

#### Merging (with time correction)

If each of your individual subtitle files contains timecodes relative to its own starting point,
you have to supply a reference so misaligned subtitles can be automatically shifted. When you fail
to do this, your subtitles overlap and thus Titlekit assumes that you want simultaneous subtitles (which are explained in the next paragraph below this one).

```ruby
  job.have do
    file('subs_cd1.srt')
  end

  job.have do
    file('subs_cd2.srt')
    reference(:cd2_subtitles_starting_at, minutes: 0)
  end

  job.want do
    reference(:cd2_subtitles_starting_at, srt_timecode: '00:01:24,000')
    file('subs_both_cds_combined.srt')
  end
```

#### Simultaneous/multi-lanugage subtitles

Subtitles that overlap are automatically treated as simultaneous/multi-lanugage subtitles.
Titlekit then positions and formats them in the most sensible way it sees fit.

```ruby
  job.have { file('enlish.srt') }
  job.have { file('dutch.srt') }
  job.want { file('dual-language.srt') }
```

Any target format is possible, Titlekit will automatically make the best use of the formatting
features your target format provides. Pick a sophisticated subtitle format, and your dual
subtitles will automatically be prettier and more readable!

```ruby
  job.have { file('enlish.srt') }
  job.have { file('dutch.srt') }
  job.want { file('dual-language-prettier.ass') }
```

You can also go crazy if you want, Titlekit can handle it.

```ruby
  job.have { file('enlish.srt') }
  job.have { file('dutch.srt') }
  job.have { file('spanish.srt') }
  job.have { file('german.srt') }
  job.have { file('italian.srt') }
  job.have { file('french.srt') }
  job.have { file('portuguese.srt') }
  job.have { file('russian.srt') }
  job.want { file('messy-but-supported.ssa') }
```

#### Mixed mode Merging (implicit)

If you really need the absurdly exotic case of merging multi-part subtitles into multiple simultaneous tracks, you just need to make sure you enter them in the correct order, which is: Lanuage1/Part1 -> Language1/Part2 -> Language2/Part1 -> Language2/Part2

```ruby
  job.have { file('subs_english_chapter1.srt')
  job.have { file('subs_english_chapter2.srt')
  job.have { file('subs_french_chapter1.srt')
  job.have { file('subs_french_chapter2.srt')

  job.want do
    file('subs_multi_part_multi_track.srt')
  end
```

#### Mixed mode Merging (explicit)

If you supply explicit track identifiers by which to material should be grouped into tracks, 
you can also forget all about the otherwise required order and just go wild:

```ruby

  job.have do
    file('subs_french_chapter2.srt')
    track('le-french-track')
  end

  job.have do
    file('subs_english_chapter1.srt')
    track('the-english-one')
  end

  job.have do
    file('subs_french_chapter1.srt')
    track('le-french-track')
  end

  job.have do
    file('subs_english_chapter2.srt')
    track('the-english-one')
  end

  job.want do
    file('subs_multi_part_multi_track.srt')
  end
```

#### Multiple targets

```ruby
  job.have { file('input.srt') }
  job.want { file('output.ass') }
  job.want { file('output.ssa') }
```

#### Templates

```ruby
  job.have do
    file('input.srt')
    encoding('Shift_JIS')
    reference(:some_subtitle, subtitle: 23)
  end
  
  templ = job.want do
    file('output.srt')
    encoding('UTF-8')
    reference(:some_subtitle, hours: 0.16)
  end
  
  job.want(template: templ) { file('output.ass') }
  job.want(template: templ) { file('output.ssa') }
```

#### Explicitly control encoding detection

```ruby
  job.have do
    file('input.srt')
    encoding(:detect) # Detect the encoding with charlock_holmes if installed, otherwise rchardet19
                      # You don't need to supply this line though, it's the default behavior!
  end

  job.have do
    file('input.srt')
    encoding(:rchardet19) # Explicitly use rchardet19
  end  
  
  job.have do
    file('input.srt')
    encoding(:charlock_holmes) # Explicitly use charlock_holmes
  end
```

#### Syntax Variants

`#have` and `#want` offer three different syntax variants, which are functionally identical:

```ruby
  job.have do
    file('input.srt')
    encoding('ISO-8859-1')
  end
  
  # is identical to
  
  job.have do |have|
    have.file('input.srt')
    have.encoding('ISO-8859-1')
  end
  
  # is identical to
  
  have = job.have
  have.file('input.srt')
  have.encoding('ISO-8859-1')
```

## API Reference

http://www.rubydoc.info/gems/titlekit/frames (or generate it yourself with YARD)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
