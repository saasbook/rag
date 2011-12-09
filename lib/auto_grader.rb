class AutoGrader
  class ::NoSuchGraderError < StandardError ; end

  attr_reader :comments, :normalized_score

  def self.class_init
    Dir["lib/graders/*_grader.rb"].each { |file| load file }
  end
  
  def initialize(grader, submitted_answer, grading_rules)
    @@initialized ||= AutoGrader.class_init
    if submitted_answer.nil? || submitted_answer.empty?
      @normalized_score = 0.0
      @comments = 'You did not submit any answer.'
    else
      begin
        grader_klass = Object.const_get(grader)
        grader_klass.send(:new, submitted_answer, grading_rules)
      rescue NameError => e
        raise AutoGrader::NoSuchGraderError, "Can't find grading strategy for #{grader}"
      end
    end
  end

  def grade! ; end

end

