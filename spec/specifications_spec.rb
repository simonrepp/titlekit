require File.join(File.expand_path(__dir__), 'spec_helper')

shared_examples 'a specification' do

  describe '#new' do
    it 'creates a new specification' do
      expect(described_class.new).to be_a_kind_of(described_class)
    end
  end

  describe '#encoding' do
    let(:specification) do
      described_class.new.encoding('utf-8')
    end

    it 'returns the specification' do
      expect(specification).to be_a_kind_of(described_class)
    end

    it 'returns the set encoding' do
      expect(specification.encoding).to eq('utf-8')
    end
  end

  describe '#file' do
    let(:specification) do
      described_class.new.file('the/path.srt')
    end

    it 'returns the specification' do
      expect(specification).to be_a_kind_of(described_class)
    end

    it 'returns the set path' do
      expect(specification.file).to eq('the/path.srt')
    end
  end

  describe '#fps' do
    let(:specification) do
      described_class.new.fps(25)
    end

    it 'returns the specification' do
      expect(specification).to be_a_kind_of(described_class)
    end

    it 'returns the set framerate' do
      expect(specification.fps).to eq(25)
    end
  end

  describe '#reference' do
    context 'specifying a minute' do
      let(:specification) do
        described_class.new.reference(:some_point, minutes: 3.5)
      end

      it 'returns the specification' do
        expect(specification).to be_a_kind_of(described_class)
      end

      it 'returns the set named reference for a timecode' do
        expect(specification.references[:some_point][:timecode]).to eq(210)
      end
    end

    context 'specifying an SRT timecode' do
      let(:specification) do
        described_class.new.reference(:some_point, srt_timecode: '00:03:30,000')
      end

      it 'returns the specification' do
        expect(specification).to be_a_kind_of(described_class)
      end

      it 'returns the set named reference for a timecode' do
        expect(specification.references[:some_point][:timecode]).to eq(210)
      end
    end

    context 'specifying an ASS timecode' do
      let(:specification) do
        described_class.new.reference(:some_point, ass_timecode: '0:03:30.00')
      end

      it 'returns the specification' do
        expect(specification).to be_a_kind_of(described_class)
      end

      it 'returns the set named reference for a timecode' do
        expect(specification.references[:some_point][:timecode]).to eq(210)
      end
    end

    context 'specifying an SSA timecode' do
      let(:specification) do
        described_class.new.reference(:some_point, ssa_timecode: '0:03:30.00')
      end

      it 'returns the specification' do
        expect(specification).to be_a_kind_of(described_class)
      end

      it 'returns the set named reference for a timecode' do
        expect(specification.references[:some_point][:timecode]).to eq(210)
      end
    end
  end
end

describe Titlekit::Specification do
  it_behaves_like 'a specification'
end

describe Titlekit::Have do
  it_behaves_like 'a specification'

  describe '#reference' do
    context 'specifying a subtitle' do
      let(:specification) do
        described_class.new.reference(:some_point, subtitle: 23)
      end

      it 'returns the specification' do
        expect(specification).to be_a_kind_of(described_class)
      end

      it 'returns the set named reference for a subtitle' do
        expect(specification.references[:some_point][:subtitle]).to eq(23)
      end
    end
  end
end

describe Titlekit::Want do
  it_behaves_like 'a specification'
end
