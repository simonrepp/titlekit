require File.join(File.expand_path(__dir__), '../spec_helper')

describe Titlekit::Job do

  describe 'Automatic grouping' do
    
    context 'with an implicit single track' do
      before(:all) do
        @ins = %w{one two}.map do |file|
          File.join(__dir__, 'single_track', "#{file}.srt")
        end
        @out = File.join(__dir__, 'single_track', 'out.srt')
        @expected = File.join(__dir__, 'single_track', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new
        @ins.each { |file| job.have.file(file).encoding('UTF-8') }
        job.want.file(@out)
        
        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end

   context 'with implicit dual tracks' do
      before(:all) do
        @ins = %w{one two}.map do |file|
          File.join(__dir__, 'dual_tracks', "#{file}.srt")
        end
        @out = File.join(__dir__, 'dual_tracks', 'out.srt')
        @expected = File.join(__dir__, 'dual_tracks', 'expected.srt')

        File.delete(@out) if File.exist?(@out)
      end

      it 'runs the job' do
        job = Titlekit::Job.new
        @ins.each { |file| job.have.file(file).encoding('UTF-8') }
        job.want.file(@out)
        
        expect(job.run).to be true
      end

      it 'delivers the expected output' do
        expect(FileUtils.compare_file(@out, @expected)).to be true
      end
    end    
  end
end