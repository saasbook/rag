class CodeGrader < AutoGrader
  class ::NoSuchSpecError < StandardError ; end
  require 'rspec'
  def initialize(submitted_answer, grading_rules)
    @code = submitted_answer
    @normalized_score = 0.0
    @comments = ''
    # make sure exactly one of specdir, specfile is given
    @specfiles = [grading_rules['specfile']]
    unless @specfile.all? { |s| s =~ /_spec.rb$/ && File.readable?(s) }
      raise NoSuchSpecError, "Specfile #{s} not found"
    end
  end
    
end
