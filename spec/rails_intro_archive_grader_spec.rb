require 'spec_helper'

describe RailsIntroArchiveGrader do

   describe "#new" do
     it 'initializes instance variables' do
       File.stub(readable?: true)
       grader = RailsIntroArchiveGrader.new('archive', { spec: 'grading_rules' })
       expect(grader.instance_variable_get(:@heroku_uri)).to eq('http://localhost:3000')
       expect(grader.instance_variable_get(:@archive)).to eq('archive')
     end
     it 'raises an error when spec file is not readable' do
       expect {RailsIntroArchiveGrader.new(
           'archive', { spec: 'FAKE' })}.to raise_error(RspecGrader::NoSuchSpecError, /Specfile FAKE not found/)
     end
   end

   describe "#run_process" do
     it 'runs a process' do
       expect {RailsIntroArchiveGrader.run_process('rm -rf FAKEDIR', '.')}.not_to raise_error
     end
     #it 'initializes instance variables' do
     #  RailsIntroArchiveGrader.run_process('rm ./FAKEDIR', '.')
     #  expect(RailsIntroArchiveGrader.instance_variable_get(:@output)).to match ""
     #  expect(RailsIntroArchiveGrader.instance_variable_get(:@errors)).to match "No such file or directory"
     #  expect(RailsIntroArchiveGrader.instance_variable_get(:@status.inspect)).to match "success"
     #
     #end
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
  #    it 'should render "index"' do
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