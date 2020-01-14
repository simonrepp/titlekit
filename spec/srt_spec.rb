require File.join(File.expand_path(__dir__), 'spec_helper')

describe Titlekit::SRT do

  describe '.import' do

    context 'with a simple file' do
      let(:subtitles) do
        Titlekit::SRT.import(File.read('spec/files/srt/simple.srt'))
      end

      it 'parses and builds 3 subtitles' do
        expect(subtitles.length).to eq(3)
      end

      it 'parses and builds correct ids' do
        expect(subtitles[0][:id]).to eq(1)
      end

      it 'parses and builds correct timecodes' do
        expect(subtitles[1][:start]).to eq(24)
        expect(subtitles[1][:end]).to eq(37.8)
      end

      it 'parses and builds correct lines' do
        expect(subtitles[2][:lines]).to eq("- I ...\n- Enough!!!")
      end
    end

    context 'with an authentic file' do
      let(:subtitles) do
        Titlekit::SRT.import(File.read('spec/files/srt/authentic.srt'))
      end

      it 'parses and builds 600 subtitles' do
        expect(subtitles.length).to eq(600)
      end

      it 'parses and builds correct ids' do
        expect(subtitles[599][:id]).to eq(600)
      end

      it 'parses and builds correct timecodes' do
        expect(subtitles[7][:end]).to eq(22.952)
        expect(subtitles[299][:start]).to eq(1426.564)
        expect(subtitles[299][:end]).to eq(1428.759)
      end

      it 'parses and builds correct lines' do
        expect(subtitles[0][:lines]).to eq("<i>(male narrator) Previously\r\non Battlestar Galactica.</i>")
      end
    end

    context 'with a file that contains coordinates' do
      let(:subtitles) do
        Titlekit::SRT.import(File.read('spec/files/srt/coordinates.srt'))
      end

      it 'parses and builds 3 subtitles' do
        expect(subtitles.length).to eq(3)
      end

      it 'parses and builds correct ids' do
        expect(subtitles[0][:id]).to eq(1)
      end

      it 'parses and builds correct timecodes' do
        expect(subtitles[1][:start]).to eq(16)
        expect(subtitles[1][:end]).to eq(32)
      end

      it 'parses and builds correct lines' do
        expect(subtitles[2][:lines]).to eq("A: Still I'm implementing them; Whatevs.")
      end

      it 'ignores the display coordinates' do
        # just fyi
      end
    end
  end

  describe '.export' do
    it 'should export valid SRT' do
      subtitles = [
        {
          id: 1,
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
1
00:00:01,500 --> 00:00:03,700
Eine feine Testung haben sie da!

2
00:00:01,500 --> 00:00:03,700
¡Sí claro! Pero que lastima que no es 100% español ...

3
00:00:01,500 --> 00:00:03,700
Oh yeah ... 寧為太平犬，不做亂世人

      EXPECTED

      expect(Titlekit::SRT.export(subtitles)).to eq(expected)
    end
  end

  describe '.build_timecode' do
    it 'builds an SRT timecode from a float timecode value' do
      expect(Titlekit::SRT.build_timecode(35.9678)).to eq('00:00:35,968')
    end
  end

  describe '.parse_timecode' do
    it 'obtains a float timecode value from an SRT timecode' do
      expect(Titlekit::SRT.parse_timecode('00:00:35,968')).to eq(35.968)
    end
  end
end
