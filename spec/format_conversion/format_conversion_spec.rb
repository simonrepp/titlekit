require File.join(File.expand_path(__dir__), '../spec_helper')

describe Titlekit::Job do

  describe 'Format conversion' do

    context 'From ASS to SRT' do
      before(:all) do
        @in = File.join(__dir__, 'ass_srt', 'in.ass')
        @out = File.join(__dir__, 'ass_srt', 'out.srt')
        @expected = File.join(__dir__, 'ass_srt', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new

        have = job.have
        have.file(@in)

        want = job.want
        want.file(@out)

        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end

    context 'From SRT to ASS' do
      before(:all) do
        @in = File.join(__dir__, 'srt_ass', 'in.srt')
        @out = File.join(__dir__, 'srt_ass', 'out.ass')
        @expected = File.join(__dir__, 'srt_ass', 'expected.ass')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new

        have = job.have
        have.file(@in)

        want = job.want
        want.file(@out)

        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end

    context 'From SRT to SSA' do
      before(:all) do
        @in = File.join(__dir__, 'srt_ssa', 'in.srt')
        @out = File.join(__dir__, 'srt_ssa', 'out.ssa')
        @expected = File.join(__dir__, 'srt_ssa', 'expected.ssa')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new

        have = job.have
        have.file(@in)

        want = job.want
        want.file(@out)

        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end

    context 'From SSA to SRT' do
      before(:all) do
        @in = File.join(__dir__, 'ssa_srt', 'in.ssa')
        @out = File.join(__dir__, 'ssa_srt', 'out.srt')
        @expected = File.join(__dir__, 'ssa_srt', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new

        have = job.have
        have.file(@in)

        want = job.want
        want.file(@out)

        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end
  end
end
