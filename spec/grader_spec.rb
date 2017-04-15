require 'spec_helper'

describe 'Command Line Interface' do
  it 'should exist' do
    expect(Grader).not_to be_nil
  end
  it "should define a cli method" do
    lambda { Grader.cli }.should_not raise_error(::NoMethodError)
  end
  it 'should display help when args are not appropriate' do
    expect(Grader.cli(["something"])).to eq Grader.help
  end
  describe 'should produce appropriate response to correct WeightedRspecGrader arguments' do
    before(:each) do
      IO.should_receive(:read).with("correct_example.rb").and_return("some code")
      args = '1', 'WeightedRspecGrader',"some code",{:spec => "correct_example.spec.rb"}
      @auto_grader = mock('AutoGrader')
      @auto_grader.should_receive(:grade!)
      AutoGrader.should_receive(:create).with(*args).and_return(@auto_grader)
    end
    it 'should produce correctly formatted output' do
      @auto_grader.should_receive(:normalized_score).with(100).and_return(67)
      @auto_grader.should_receive(:comments).and_return('stuff')
      grader = Grader.cli(["-t","WeightedRspecGrader","correct_example.rb","correct_example.spec.rb"])
      expect(grader.to_s).not_to eq Grader.help
    end
  end
  it 'should be able to handle passing in a github username' do
    args = '1', 'GithubRspecGrader',"tansaku",{:spec => "github_spec.rb"}
    auto_grader = mock('AutoGrader')
    auto_grader.should_receive(:grade!)
    auto_grader.should_receive(:normalized_score).with(100).and_return(67)
    auto_grader.should_receive(:comments).and_return('stuff')
    AutoGrader.should_receive(:create).with(*args).and_return(auto_grader)
    grader = Grader.cli(["-t","GithubRspecGrader","tansaku","github_spec.rb"])
    expect(grader).not_to eq Grader.help
    #AutoGrader.create('1', 'WeightedRspecGrader', IO.read(ARGV[0]), :spec => ARGV[1])
  end
  it 'should be able to handle feature grader arguments' do
    cli_args = ['-t','HW3Grader','-a','/tmp/','features.tar.gz','hwz.yml']
    grd_args = ['3', 'HW3Grader','features.tar.gz',{:spec => 'hwz.yml'}]
    Kernel.should_receive(:const_get).with('HW3Grader').and_return(HW3Grader)
    HW3Grader.should_receive(:format_cli).with(cli_args).and_return(grd_args)
    execute cli_args, grd_args
  end
  @MOCK_RESULTS = 'MOCK_RESULTS'
  def mock_auto_grader
    auto_grader = double('AutoGrader')
    auto_grader.should_receive(:grade!)
    auto_grader.should_receive(:normalized_score).with(100).and_return(67)
    auto_grader.should_receive(:comments).and_return(@MOCK_RESULTS)
    return auto_grader
  end
  def execute(cli_args, grader_args, expected=/#{@MOCK_RESULTS}/)
    AutoGrader.should_receive(:create).with(*grader_args).and_return(mock_auto_grader)
    grader = Grader.cli cli_args
    expect(grader).to match expected
    return grader
  end
  xit 'should be able to receive different arguments depending on the grader specified' do
    #HW1 e.g. new_grader -t WeightedRspecGrader "#{PFX}/correct_example.rb", "#{PFX}/correct_example.spec.rb"
    #HW1.5 e.g. new_grader -t HerokuRspecGrader? github_user_name specfile.rb
    #HW2 e.g. new_grader -t HerokuRspecGrader submission_uri specfile.rb
    #HW3 e.g. new_grader -t HW3Grader -a /path/to/app/ input.tar.gz description.yml
    #HW4 e.g. new_grader -t HW4Grader input.tar.gz description.yml
    #HW5 e.g. new_grader -t HW5Grader submission_uri admin_user admin_password specfile.rb
  end
end
