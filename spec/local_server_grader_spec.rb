require 'spec_helper'
# require 'webrick'

describe LocalServerGrader do

  before(:each) do
    File.stub(readable?: true)
    @grader = LocalServerGrader.new('archive', { spec: 'grading_rules' })
    @logger=Logger.new(STDOUT)
    @grader.log=@logger
    @grader.set_log_level(Logger::WARN)
  end

  describe '#new' do
    it 'raises an error when spec file is not readable' do
      File.stub(readable?: false)
      expect {LocalServerGrader.new(
           'archive', { spec: 'FAKE' })}.to raise_error(RspecGrader::NoSuchSpecError, /Specfile FAKE not found/)
    end
    it 'initializes instance variables' do
      expect(@grader.instance_variable_get(:@host)).to eq('127.0.0.1')
      expect(@grader.instance_variable_get(:@port)).to eq('3000')
      expect(@grader.instance_variable_get(:@heroku_uri)).to eq('http://127.0.0.1:3000')
      expect(@grader.instance_variable_get(:@archive)).to eq('archive')
      expect(@grader.instance_variable_get(:@log)).not_to eq(nil)
    end
  end

  describe '#run_process' do
    it 'runs a process' do
       expect {@grader.run_process('rm -rf FAKEi?DIR')}.not_to raise_error
    end
    it 'initializes instance variables from the results when failing' do
       expect(@logger).to receive(:error)
       @grader.run_process('rm ./FAKEi?DIR')
       expect(@grader.instance_variable_get(:@p_out)).to match ''
       expect(@grader.instance_variable_get(:@p_errs)).to match 'No such file or directory'
       expect(@grader.instance_variable_get(:@p_stat).success?).to be false
    end
    it 'initializes instance variables from the results when succeeding' do
       expect(@logger).not_to receive(:error)
       @grader.run_process('ls -la', '.')
       expect(@grader.instance_variable_get(:@p_out)).to match '.'
       expect(@grader.instance_variable_get(:@p_errs)).to match ''
       expect(@grader.instance_variable_get(:@p_stat).success?).to be true
    end
  end

  describe '#process_running?' do
    it 'finds a running process' do
      expect(@grader.process_running?(1)).to be_true
    end
    it 'handles not finding a process' do
      expect(@grader.process_running?(-444666)).to be_false
    end
    it 'may have to handle process detection differently on different platforms' do
      Process.stub(getpgid: false)
      expect(@grader.process_running?(Process.pid)).to be_true
    end
    it 'logs error but does not raise if the process is owned by another' do
      Process.stub(:getpgid).and_raise Errno::EPERM
      expect(@logger).to receive(:error)
      expect {@grader.process_running?(Process.pid)}.not_to raise_error
    end

  end

  describe '#rails_up_timeout' do
    it 'waits for the server to start up' do
      @grader.stub(app_loaded?: true)
      expect {@grader.rails_up_timeout(2,1)}.not_to raise_error
    end
    #TODO better to just log and return?
    it 'times out if rails never gets up' do
      @grader.stub(app_loaded?: false)
      @grader.stub(process_running: false)
      expect {@grader.rails_up_timeout(2,2)}.to raise_error(Timeout::Error, /execution expired/)
    end
    it 'raises ArgumentError if the polling interval is larger than the timeout' do
      expect {@grader.rails_up_timeout(2,10)}.to raise_error(ArgumentError)
    end
    it 'raises ArgumentError if polling is set to zero' do
      expect {@grader.rails_up_timeout(20,0)}.to raise_error(ArgumentError)
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
    it 'returns false when it has any different error' do
      @grader.instance_variable_set(:@heroku_uri,'CAUSE-ERROR')
      expect(@grader.app_loaded?).to be false
    end
    it 'gets connection refused error when the uri is valid, but not existent' do
       expect(@logger).to receive(:info).with(/ECONNREFUSED/)
       @grader.app_loaded?
    end
  end

  describe '#kill_port_process!' do
    it 'kills any process running on the port' do
      #had rails working, tried webrick but locked up ports
      pid = Process.fork do
        exec 'sleep 30'
      end
      Process.detach pid
     # sleep 3
      expect(@grader.process_running?(pid)).not_to be_false
      @grader.kill_port_process!(pid)
      expect(@grader.process_running?(pid)).to be_false
    end
    it 'exits OK if no process was running' do
      expect {@grader.kill_port_process!(nil)}.not_to raise_error
    end
    it 'raises error if the process cannot be killed' do
      Process.stub(:kill)
      @grader.stub(process_running?: true)
      expect {@grader.kill_port_process!(666)}.to raise_error(LocalServerGrader::ProcessUnkillableError)
    end
  end

  describe '#escalating_kill' do
    it 'kills process with increasing insistence' do
      Process.stub(kill: [0,1])
      expect(Process).to receive(:kill).with('INT', 555).and_return(0)
      expect(Process).to receive(:kill).with('KILL', 555).and_return(1)
      @grader.escalating_kill(555)
    end    
    it 'logs errors from non-existent process arguments' do
      expect(@logger).to receive(:warn)
      @grader.escalating_kill(-444)
    end
    it 'logs errors from nil input' do
      expect(@logger).to receive(:warn)
      @grader.escalating_kill(nil)
    end
    
  end

  describe '#grade!' do
    before(:each) do
      status = double(Process::Status, success?: true)
      Open3.stub(capture3: ['ouput','errors', status] )
      @grader.stub(:run_process)
      @grader.stub(:rails_up_timeout).and_return
      # stub the first call only, simplecov wants it later
      IO.stub(:read) {IO.unstub(:read)}
      RspecRunner.any_instance.stub(:read_spec_file).with('grading_rules').and_return('something')
      @runner = RspecRunner.new('code', 'grading_rules')
      @runner.stub(output: "blah [10 points] \n blah (FAILED [10 points])")
      RspecRunner.stub(:new).and_return(@runner)
    end
    it 'kills other processes using the port, before and after running' do
      @grader.stub(process_running?: true)
      expect(@grader).to receive(:kill_port_process!).twice
      @grader.grade!
    end
    it 'grades the homework' do
      RspecRunner.should_receive(:new).and_return(@runner)
      @grader.grade!
      expect(@grader.instance_variable_get(:@raw_score)).to eql 10
      expect(@grader.instance_variable_get(:@raw_max)).to eql 20
      expect(@grader.instance_variable_get(:@comments)).
          to eql "blah [10 points] \n blah (FAILED [10 points])"
    end
  end

end
