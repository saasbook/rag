require './lib/auto_grader.rb'

class Grader
  def initialize(auto_grader)
    @g = auto_grader
  end
  def self.cli(args)
    return self.help if args.length != 4
    type = args[1]
    args[2] = IO.read(args[2]) if type == 'WeightedRspecGrader'
    g = AutoGrader.create('1', args[1] ,args[2] ,:spec => args[3])
    g.grade!
    return Grader.new(g)
  end
  def to_s
    <<EndOfFeedback
    "Score out of 100: #{@g.normalized_score(100)}\n"+
    "---BEGIN rspec comments---\n#{'-'*80}\n#{@g.comments}\n#{'-'*80}\n---END rspec comments---"
EndOfFeedback
  end
  def self.help
    <<EndOfHelp
Usage: #{$0} -t GraderType submission specfile.rb

Creates an autograder of the specified subclass and grades the submission file with it.

For example, try these, where PREFIX=rag/spec/fixtures:

#{$0} -t WeightedRspecGrader $PREFIX/correct_example.rb $PREFIX/correct_example.spec.rb
#{$0} -t WeightedRspecGrader $PREFIX/example_with_syntax_error.rb $PREFIX/correct_example.spec.rb
#{$0} -t WeightedRspecGrader $PREFIX/example_with_runtime_exception.rb $PREFIX/correct_example.spec.rb

EndOfHelp
  end
end