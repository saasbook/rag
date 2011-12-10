class AutoGrader
  class ::NoSuchGraderError < StandardError ; end

  attr_reader :comments, :normalized_score, :question_id

  def self.class_init
    Dir["lib/graders/*_grader.rb"].each { |file| load file }
  end
  
  def self.create(question_id, grader, submitted_answer, grading_rules)
    @@initialized ||= AutoGrader.class_init
    if submitted_answer.nil? || submitted_answer.empty?
      AutoGrader.new(question_id)
    else
      begin
        grader_klass = Object.const_get(grader)
        obj = grader_klass.send(:new, submitted_answer, grading_rules)
        obj.instance_variable_set('@question_id', question_id)
        return obj
      rescue NameError => e
        raise AutoGrader::NoSuchGraderError, "Can't find grading strategy for #{grader}"
      end
    end
  end

  def grade! ; end

  private
  
  # not to be used externally
  def initialize(question_id)
    @normalized_score = 0
    @comments = 'You did not submit any answer.'
    @question_id = question_id
  end

end

