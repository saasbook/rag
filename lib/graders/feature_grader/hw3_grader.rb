require_relative 'feature_grader'

class HW3Grader < FeatureGrader
  def self.cli(args)
    t_opt, type, a_opt, tmp_dir, archive, hw_yml = args
    begin
      start_dir = Dir.getwd
      Dir.chdir tmp_dir
      do_cli autograder_args(args)
    ensure
      Dir.chdir start_dir
    end
  end
  def self.autograder_args(args)
    raise ArgumentError unless args.respond_to?(:length) && args.length == 6
    type, archive , hw_yml  = args[1], args[4], args[5]
    return [ '3', type, archive, {:spec => hw_yml}]
  end

  private

  def self.do_cli(auto_args)
    begin
      g = AutoGrader.create(*auto_args)
      g.grade!
      Grader.feedback g
    rescue Object => e
      STDERR.puts "*** FATAL: #{e.respond_to?(:message) ? e.message : 'unspecified error'}"
    end
  end
end
