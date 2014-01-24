require_relative 'rspec_grader'

class WeightedRspecGrader < RspecGrader

  @assignment_id = '1'

  def self.format_cli(t_option, type, answer, specs)
    answer = IO.read answer # make -b a command line option?
    return super(t_option, type, answer, specs)
  end

  def grade!
    runner =  RspecRunner.new(@code, @specfile)
    runner.run

    @raw_score = 0
    @raw_max = 0
    @comments = runner.output

    runner.output.each_line do |line|
      if line =~ /\[(\d+) points?\]/
        points = $1.to_i
        @raw_max += points
        @raw_score += points unless line =~ /\(FAILED([^)])*\)/
      elsif line =~ /^Failures:/
        mode = :log_failures
        break
      end
    end
  end
end

