require File.join(File.expand_path(__dir__), '../spec_helper')

describe Titlekit::Job do

  describe 'Encoding detection' do

    context 'with exhibit A' do
      before(:all) do
        @in = File.join(__dir__, 'a', 'in.ass')
        @out = File.join(__dir__, 'a', 'out.ass')
        @expected = File.join(__dir__, 'a', 'expected.ass')

        File.delete(@out) if File.exist?(@out)
      end

      it 'tries its best and takes graceful actions no matter what' do
        job = Titlekit::Job.new

        have = job.have
        have.file(@in)

        want = job.want
        want.file(@out)

        job.run

        expect(job.report.join).to include('detected')
      end
    end

    context 'with exhibit B' do

      before(:all) do
        @in = File.join(__dir__, 'b', 'in.srt')
        @out = File.join(__dir__, 'b', 'out.srt')
        @expected = File.join(__dir__, 'b', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'tries its best and takes graceful actions no matter what' do
        job = Titlekit::Job.new

        have = job.have
        have.file(@in)

        want = job.want
        want.file(@out)

        job.run

        expect(job.report.join).to include('detected')
      end
    end

    context 'with exhibit C' do

      before(:all) do
        @in = File.join(__dir__, 'c', 'in.srt')
        @out = File.join(__dir__, 'c', 'out.srt')
        @expected = File.join(__dir__, 'c', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'tries its best and takes graceful actions no matter what' do
        job = Titlekit::Job.new

        have = job.have
        have.file(@in)

        want = job.want
        want.file(@out)

        job.run

        expect(job.report.join).to include('detected')
      end
    end
  end
end
