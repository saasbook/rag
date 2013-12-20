require './lib/auto_grader.rb'

class Grader

  def self.cli(args)
    return help unless args.respond_to? 'length' and args.length >= 4
    case type = args[1]
      when 'HW3Grader' then return handle_hw3_grader args
      when /RspecGrader/ then return handle_rspec_grader args
      else return help
    end
  end

  def self.handle_rspec_grader(args)
    t_opt, type, file, specs = args
    file = IO.read file if type == 'WeightedRspecGrader'
    g = AutoGrader.create '1', type ,file ,:spec => specs
    g.grade!
    feedback g
  end

  # TODO refactor with rag/grade3.rb and rag/features/step_definitions/subject_code_steps.rb
  def self.handle_hw3_grader(args)
    t_opt, type, a_opt, tmp_dir, archive, hw_yml = args
    begin
      start_dir = Dir::getwd
      begin
        Dir::chdir tmp_dir
        g = AutoGrader.create '3', type, archive, :spec => hw_yml
        g.grade!
        feedback g
      rescue Object => e
        STDERR.puts "*** FATAL: #{e.respond_to? :message ? e.message : 'unspecified error'}"
      end
    ensure
      Dir::chdir start_dir
    end
  end

  def self.feedback(g)
    <<EndOfFeedback
Score out of 100: #{g.normalized_score(100)}
---BEGIN rspec comments---
#{'-'*80}
    #{g.comments}
    #{'-'*80}
---END rspec comments---
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
