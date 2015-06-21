require File.join(File.expand_path(__dir__), 'spec_helper')

describe Titlekit::Job do

  describe '#new' do
    it 'creates a new instance' do
      expect(Titlekit::Job.new).to be_a_kind_of(Titlekit::Job)
    end
  end

  describe '#have' do
    context 'without a block' do
      let(:have) do
        Titlekit::Job.new.have
      end

      it 'returns an instance of Have' do
        expect(have).to be_a_kind_of(Titlekit::Have)
      end
    end

    context 'with a block, passing no variable' do
      let(:have) do
        Titlekit::Job.new.have do
          encoding('utf-8')
          file('spec/files/srt/simple.srt')
          fps(25)
        end
      end

      it 'returns an instance of Have' do
        expect(have).to be_a_kind_of(Titlekit::Have)
      end

      it 'assigns specification properties in the block' do
        expect(have.encoding).to eq('utf-8')
        expect(have.file).to be
        expect(have.fps).to eq(25)
      end
    end

    context 'with a block, passing a variable' do
      let(:have) do
        Titlekit::Job.new.have do |have|
          have.encoding('utf-8')
          have.file('spec/files/srt/simple.srt')
          have.fps(25)
        end
      end

      it 'returns an instance of Have' do
        expect(have).to be_a_kind_of(Titlekit::Have)
      end

      it 'assigns specification properties in the block' do
        expect(have.encoding).to eq('utf-8')
        expect(have.file).to be
        expect(have.fps).to eq(25)
      end
    end
  end

  describe '#want' do
    context 'without a block' do
      let(:want) do
        Titlekit::Job.new.want
      end

      it 'returns an instance of Want' do
        expect(want).to be_a_kind_of(Titlekit::Want)
      end
    end

    context 'with a block, passing no variable' do
      let(:want) do
        Titlekit::Job.new.want do
          encoding('utf-8')
          file('out.srt')
          fps(23.976)
        end
      end

      it 'returns an instance of Want' do
        expect(want).to be_a_kind_of(Titlekit::Want)
      end

      it 'assigns specification properties in the block' do
        expect(want.encoding).to eq('utf-8')
        expect(want.file).to eq('out.srt')
        expect(want.fps).to eq(23.976)
      end
    end

    context 'with a block, passing a variable' do
      let(:want) do
        Titlekit::Job.new.want do |want|
          want.encoding('utf-8')
          want.file('out.srt')
          want.fps(23.976)
        end
      end

      it 'returns an instance of Want' do
        expect(want).to be_a_kind_of(Titlekit::Want)
      end

      it 'assigns specification properties in the block' do
        expect(want.encoding).to eq('utf-8')
        expect(want.file).to eq('out.srt')
        expect(want.fps).to eq(23.976)
      end
    end
  end

  describe '#run' do

    context 'with input files that don\'t exist' do
      it 'gracefully aborts the job' do
        job = Titlekit::Job.new
        job.have { file('something/that/without/doubt/wont/exist.srt') }
        job.want { file('something/that/does/not/matter/anyway.ass') }

        expect(job.run).to be false
        expect(job.report.join).to include('Failure while reading')
      end
    end

    context 'with output files that can\'t be created' do
      it 'gracefully aborts the job' do
        job = Titlekit::Job.new
        job.have { file('spec/files/srt/simple.srt') }
        job.want { file('!@#$%^&*()|?/\\.ass') }

        expect(job.run).to be false
        expect(job.report.join).to include('Failure while writing')
      end
    end

    context 'with an input format that is not supported' do
      it 'gracefully aborts the job' do
        job = Titlekit::Job.new
        job.have { file('spec/files/try/unsupported.try') }
        job.want { file('!@#$%^&*()|?/\.ass') }

        expect(job.run).to be false
        expect(job.report.join).to include('Failure while importing TRY')
      end
    end

    context 'with an output format that is not supported' do
      it 'gracefully aborts the job' do
        job = Titlekit::Job.new
        job.have { file('spec/files/srt/simple.srt') }
        job.want { file('spec/files/try/unsupported-output.try') }

        expect(job.run).to be false
        expect(job.report.join).to include('Failure while exporting TRY')
      end
    end
  end
end
