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
    it 'can take it if the interval is larger than the timeout' do
      @grader.stub(app_loaded?: false)
      expect {@grader.rails_up_timeout(2,10).to_s}.to raise_error(Timeout::Error, /execution expired/)
    end
  end


end

  # it 'initializes instance variables' do
  #feature_grader = FeatureGrader.new('features_archive', { spec: 'test.yml.file' })
  #expect(feature_grader.instance_variable_get(:@output)).to eq([])
  #expect(feature_grader.instance_variable_get(:@m_output)).to be_a(Mutex)
  #expect(feature_grader.instance_variable_get(:@features)).to eq([])
  #
  #expect(feature_grader.instance_variable_get(:@features_archive)).to eq 'features_archive'
  #expect(feature_grader.instance_variable_get(:@description)).to eq 'test.yml.file'
  #
  #end
  #
  #
  #
  #
  # describe EventsController do
  #  let(:event) { @event }
  #  let(:valid_session) { {} }
  #
  #  before :each do
  #    @event = FactoryGirl.create(:event)
  #    @events = @event.current_occurences
  #  end
  #
  #  describe 'GET index' do
  #    it 'should render 'index'' do
  #      get :index
  #      assigns(:events).should eq(@events)
  #      response.should render_template :index
  #    end
  #  end
  #
  #  describe 'GET show' do
  #    before(:each) do
  #      get :show, {:id => event.to_param}, valid_session
  #    end
  #
  #    it 'assigns the requested event as @event' do
  #      assigns(:event).should eq(event)
  #    end
  #
  #    it 'renders the show template' do
  #      expect(response).to render_template 'show'
  #    end
  #  end