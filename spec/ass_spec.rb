require File.join(File.expand_path(__dir__), 'spec_helper')

describe Titlekit::ASS do

  describe '.import' do

    context 'with a simple file' do
      let(:subtitles) do
        Titlekit::ASS.import(File.read('spec/files/ass/simple.ass'))
      end

      it 'parses and builds 2 subtitles' do
        expect(subtitles.length).to eq(2)
      end

      it 'parses and builds correct ids' do
        expect(subtitles[0][:id]).to eq(1)
      end

      it 'parses and builds correct timecodes' do
        expect(subtitles[1][:start]).to eq(120.99)
        expect(subtitles[1][:end]).to eq(122.87)
      end

      it 'parses and builds correct lines' do
        expect(subtitles[1][:lines]).to eq('Est-ce vraiment Naruto ?')
      end
    end

    context 'with a hard file' do
      let(:subtitles) do
        Titlekit::ASS.import(File.read('spec/files/ass/hard.ass'))
      end

      it 'parses and builds 17 subtitles' do
        expect(subtitles.length).to eq(17)
      end

      it 'parses and builds correct ids' do
        expect(subtitles[0][:id]).to eq(1)
      end

      it 'parses and builds correct timecodes' do
        expect(subtitles[8][:start]).to eq(4)
        expect(subtitles[8][:end]).to eq(6)
      end

      it 'parses and builds correct lines' do
        expect(subtitles[1][:lines]).to eq("هل تعمل اللغة العربية؟\n")
      end
    end

    context 'with a file including a BOM' do
      let(:subtitles) do
        Titlekit::ASS.import(File.read('spec/files/ass/bom.ass'))
      end

      it 'parses and builds 2 subtitles' do
        expect(subtitles.length).to eq(2)
      end

      it 'parses and builds correct ids' do
        expect(subtitles[0][:id]).to eq(1)
      end

      it 'parses and builds correct timecodes' do
        expect(subtitles[1][:start]).to eq(120.99)
        expect(subtitles[1][:end]).to eq(122.87)
      end

      it 'parses and builds correct lines' do
        expect(subtitles[1][:lines]).to eq('Agreed.')
      end
    end
  end

  describe '.export' do
    it 'should export valid ASS' do
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
ScriptType: v4.00+

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,16,&H00FFFFFF,&H00FFFFFF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1
Style: Top,Arial,16,&H00FFFFFF,&H00FFFFFF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,8,20,20,20,1
Style: Middle,Arial,16,&H00FFFFFF,&H00FFFFFF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,5,20,20,20,1
Style: EDF393,Arial,16,&H0093F3ED,&H0093F3ED,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1
Style: F5E665,Arial,16,&H0065E6F5,&H0065E6F5,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1
Style: FFC472,Arial,16,&H0072C4FF,&H0072C4FF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1
Style: FFA891,Arial,16,&H0091A8FF,&H0091A8FF,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1
Style: 89BABE,Arial,16,&H00BEBA89,&H00BEBA89,&H40000000,&H40000000,0,0,0,0,100,100,0,0.00,1,3,0,2,20,20,20,1

[Events]
Format: Layer, Start, End, Style, Actor, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:01.50,0:00:03.70,Default,,0000,0000,0000,,Eine feine Testung haben sie da!
Dialogue: 0,0:00:01.50,0:00:03.70,Default,,0000,0000,0000,,¡Sí claro! Pero que lastima que no es 100% español ...
Dialogue: 0,0:00:01.50,0:00:03.70,Default,,0000,0000,0000,,Oh yeah ... 寧為太平犬，不做亂世人
      EXPECTED

      expect(Titlekit::ASS.export(subtitles)).to eq(expected)
    end
  end

  describe '.build_timecode' do
    it 'builds an ASS timecode from a float timecode value' do
      expect(Titlekit::ASS.build_timecode(35.9678)).to eq('0:00:35.97')
    end
  end

  describe '.parse_timecode' do
    it 'obtains a float timecode value from an ASS timecode' do
      expect(Titlekit::ASS.parse_timecode('0:00:35.96')).to eq(35.96)
      expect(Titlekit::ASS.parse_timecode('0:00:04.56')).to eq(4.56)
    end
  end
end
