require File.join(File.expand_path(__dir__), '../spec_helper')

describe Titlekit::Job do

  describe 'Transcoding' do

    context 'From ISO-8859-1 to UTF-8' do
      before(:all) do
        @in = File.join(__dir__, 'iso-8859-1_utf-8', 'in.srt')
        @out = File.join(__dir__, 'iso-8859-1_utf-8', 'out.srt')
        @expected = File.join(__dir__, 'iso-8859-1_utf-8', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new

        have = job.have
        have.encoding('ISO-8859-1')
        have.file(@in)
        
        want = job.want
        want.encoding('UTF-8')
        want.file(@out)
        
        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end

    context 'From Windows-1252 to UTF-8' do
      before(:all) do
        @in = File.join(__dir__, 'windows-1252_utf-8', 'in.srt')
        @out = File.join(__dir__, 'windows-1252_utf-8', 'out.srt')
        @expected = File.join(__dir__, 'windows-1252_utf-8', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new

        have = job.have
        have.encoding('Windows-1252')
        have.file(@in)
        
        want = job.want
        want.encoding('UTF-8')
        want.file(@out)
        
        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end

    context 'From UTF-8 to GBK' do
      before(:all) do
        @in = File.join(__dir__, 'utf-8_gbk', 'in.srt')
        @out = File.join(__dir__, 'utf-8_gbk', 'out.srt')
        @expected = File.join(__dir__, 'utf-8_gbk', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new

        have = job.have
        have.encoding('UTF-8')
        have.file(@in)
        
        want = job.want
        want.encoding('GBK')
        want.file(@out)
        
        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end

    context 'From GB2312 to ASCII' do
      before(:all) do
        @in = File.join(__dir__, 'gb2312-ascii', 'in.srt')
        @out = File.join(__dir__, 'gb2312-ascii', 'out.srt')
        @expected = File.join(__dir__, 'gb2312-ascii', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'gracefully aborts the job' do
        job = Titlekit::Job.new

        have = job.have
        have.encoding('GB2312')
        have.file(@in)
        
        want = job.want
        want.encoding('ASCII')
        want.file(@out)
        
        expect(job.run).to be false
        expect(job.report.join).to include('Failure while transcoding')
      end
    end        
  end
end