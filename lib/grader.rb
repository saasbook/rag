require './lib/auto_grader.rb'

class Grader

  # TODO use optparse like rag/grade3
  # Simply do: return Kernel.const_get(type).new(args).grade!
  def self.cli(args)
    return self.help if args.nil? || args.length < 4 || ! args[1] =~ /Grader/
    original_dir = Dir.getwd
    begin
      if args[2] == '-a'
        working_dir = args[3]
        Dir.chdir(working_dir)
        ENV['BUNDLE_GEMFILE'] = working_dir + '/Gemfile'
      end
      self.run_grader(args)
    ensure
      Dir.chdir original_dir
      ENV['BUNDLE_GEMFILE'] = original_dir + '/Gemfile'
    end
  end

  def self.run_grader(args)
    type = args[1]
    subclass = Kernel.const_get(type)
    autograder_args = subclass.format_cli(*args)
    g = AutoGrader.create(*autograder_args)
    g.grade!
    return subclass.feedback g
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

