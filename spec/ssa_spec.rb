require File.join(File.expand_path(__dir__), 'spec_helper')

describe Titlekit::SSA do

  describe '.import' do

    context 'with a simple file' do
      let(:subtitles) do
        Titlekit::SSA.import(File.read('spec/files/ssa/simple.ssa'))
      end

      it 'parses and builds 2 subtitles' do
        expect(subtitles.length).to eq(2)
      end

      it 'parses and builds correct ids' do
        expect(subtitles[0][:id]).to eq(1)
      end

      it 'parses and builds correct timecodes' do
        expect(subtitles[1][:start]).to eq(11.84)
        expect(subtitles[1][:end]).to eq(14.74)
      end

      it 'parses and builds correct lines' do
        expect(subtitles[1][:lines]).to eq('{\\a2}Story Script & Direction - MIYAZAKI Hayao')
      end
    end
  end

  describe '.export' do
    it 'should export valid SSA' do
      subtitles = [
        {
          start: 1.5,
          end: 3.7,
          lines: 'Eine feine Testung haben sie da!'
        },
        {
          id: 2,
          start: 1.5,
          end: 3.7,
          lines: '¡Sí claro! Pero que lastima que no es 100% español ...'
        },
        {
          id: 3,
          start: 1.5,
          end: 3.7,
          lines: 'Oh yeah ... 寧為太平犬，不做亂世人'
        }
      ]

      expected = <<-EXPECTED
[Script Info]
ScriptType: v4.00

[V4 Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, TertiaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, AlphaLevel, Encoding
Style: Default,Arial,16,16777215,16777215,16777215,-2147483640,0,0,1,3,0,2,70,70,40,0,0
Style: Middle,Arial,16,16777215,16777215,16777215,-2147483640,0,0,1,3,0,10,70,70,40,0,0
Style: Top,Arial,16,16777215,16777215,16777215,-2147483640,0,0,1,3,0,6,70,70,40,0,0
Style: EDF393,Arial,16,9696237,9696237,9696237,-2147483640,0,0,1,3,0,2,70,70,40,0,0
Style: F5E665,Arial,16,6678261,6678261,6678261,-2147483640,0,0,1,3,0,2,70,70,40,0,0
Style: FFC472,Arial,16,7521535,7521535,7521535,-2147483640,0,0,1,3,0,2,70,70,40,0,0
Style: FFA891,Arial,16,9545983,9545983,9545983,-2147483640,0,0,1,3,0,2,70,70,40,0,0
Style: 89BABE,Arial,16,12499593,12499593,12499593,-2147483640,0,0,1,3,0,2,70,70,40,0,0

[Events]
Format: Marked, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:01.50,0:00:03.70,Default,,0000,0000,0000,,Eine feine Testung haben sie da!
Dialogue: 0,0:00:01.50,0:00:03.70,Default,,0000,0000,0000,,¡Sí claro! Pero que lastima que no es 100% español ...
Dialogue: 0,0:00:01.50,0:00:03.70,Default,,0000,0000,0000,,Oh yeah ... 寧為太平犬，不做亂世人
      EXPECTED

      expect(Titlekit::SSA.export(subtitles)).to eq(expected)
    end
  end

  describe '.build_timecode' do
    it 'builds an SSA timecode from a float timecode value' do
      expect(Titlekit::SSA.build_timecode(35.9678)).to eq('0:00:35.97')
    end
  end

  describe '.parse_timecode' do
    it 'obtains a float timecode value from an SSA timecode' do
      expect(Titlekit::SSA.parse_timecode('0:00:35.96')).to eq(35.96)
    end
  end
end
