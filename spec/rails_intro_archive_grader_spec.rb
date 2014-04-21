require 'spec_helper'


describe RailsIntroArchiveGrader do

  before(:each) do
    File.stub(readable?: true)
    @grader = RailsIntroArchiveGrader.new('archive', { spec: 'grading_rules' })
  end


  describe '#new' do
    it 'raises an error when spec file is not readable' do
      File.stub(readable?: false)
      expect {RailsIntroArchiveGrader.new(
           'archive', { spec: 'FAKE' })}.to raise_error(RspecGrader::NoSuchSpecError, /Specfile FAKE not found/)
    end
    it 'initializes instance variables' do
      expect(@grader.instance_variable_get(:@host)).to eq('127.0.0.1')
      expect(@grader.instance_variable_get(:@port)).to eq('3000')
      expect(@grader.instance_variable_get(:@heroku_uri)).to eq('http://127.0.0.1:3000')
      expect(@grader.instance_variable_get(:@archive)).to eq('archive')
    end
  end


  describe '#run_process' do
   it 'runs a process' do
     expect {@grader.run_process('rm -rf FAKEDIR', '.')}.not_to raise_error
   end
   it 'initializes instance variables from the results when failing' do
     @grader.run_process('rm ./FAKEDIR', '.')
     expect(@grader.instance_variable_get(:@p_out)).to match ''
     expect(@grader.instance_variable_get(:@p_errs)).to match 'No such file or directory'
     expect(@grader.instance_variable_get(:@p_stat).success?).to be false
   end
   it 'initializes instance variables from the results when succeeding' do
     @grader.run_process('ls -la', '.')
     expect(@grader.instance_variable_get(:@p_out)).to match '.'
     expect(@grader.instance_variable_get(:@p_errs)).to match ''
     expect(@grader.instance_variable_get(:@p_stat).success?).to be true
   end
  end


  describe '#rails_up_timeout' do
    it 'returns when http is connected to uri' do
      @grader.stub(app_loaded?: true)
      expect {@grader.rails_up_timeout(2,1).to_s}.not_to raise_error
    end
    #TODO better to just log and return?
    it 'times out if rails never gets up' do
      @grader.stub(app_loaded?: false)
      expect {@grader.rails_up_timeout(2,1).to_s}.to raise_error(Timeout::Error, /execution expired/)
    end
    it 'times out if the interval is larger than the timeout' do
      @grader.stub(app_loaded?: false)
      expect {@grader.rails_up_timeout(2,10).to_s}.to raise_error(Timeout::Error, /execution expired/)
    end
  end


  describe '#app_loaded?' do
    it 'returns true when it connects to the uri' do
      OpenURI.stub(open_uri: true)
      expect(@grader.app_loaded?).to be true
    end
    it 'returns false when rails is not ready to connect' do
      OpenURI.stub(open_uri: false)
      expect(@grader.app_loaded?).to be false
    end
    it 'returns false when it any different error' do
      @grader.instance_variable_set(:@heroku_uri,'error')
      expect(@grader.app_loaded?).to be false
    end
  end


  describe '#kill_port_process!' do
    let(:uri) { URI.parse(@grader.instance_variable_get(:@heroku_uri)) }
    let(:port) { @grader.instance_variable_get(:@port) }

    it 'kills any process running on the port' do
      if `lsof -wni tcp:#{port}` == ''
        Process.fork do
          `cd ./spec/fixtures/ropo && rails s -p #{port}`
        end
        sleep 15
      end
      expect(`lsof -wni tcp:#{port}`).not_to eql('')
      expect((OpenURI.open_uri(uri)).status[0]).to eql("200")
      @grader.kill_port_process!
      sleep 5
      expect { OpenURI.open_uri(uri) }.to raise_error
      expect(`lsof -wni tcp:#{port}`).to eql('')
    end

    it 'exits OK if no process running on the port' do
      expect { OpenURI.open_uri(uri) }.to raise_error
      expect(`lsof -wni tcp:#{port}`).to eql('')
      expect {@grader.kill_port_process!}.not_to raise_error
    end
  end

end