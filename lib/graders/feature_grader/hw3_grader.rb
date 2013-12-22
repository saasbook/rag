require_relative 'feature_grader'

class HW3Grader < FeatureGrader
  def self.cli(args)
    t_opt, type, a_opt, tmp_dir, archive, hw_yml = args
    begin
      start_dir = Dir::getwd
      begin
        Dir::chdir tmp_dir
        g = AutoGrader.create '3', type, archive, :spec => hw_yml
        g.grade!
        Grader.feedback g
      rescue Object => e
        STDERR.puts "*** FATAL: #{e.respond_to?(:message) ? e.message : 'unspecified error'}"
      end
    ensure
      Dir::chdir start_dir
    end
  end
end
