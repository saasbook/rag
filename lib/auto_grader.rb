class AutoGrader
  class ::NoSuchGraderError < StandardError ; end

  attr_accessor :comments, :errors, :question_id

  attr_reader :raw_score, :raw_max
  protected :raw_score, :raw_max
  
  def self.create(question_id, grader, submitted_answer, grading_rules, normalize=100)
    @@initialized ||= AutoGrader.class_init
    if submitted_answer.nil? || submitted_answer.empty?
      AutoGrader.new(question_id)
    else
      begin
        obj = Object.const_get(grader).send(:new, submitted_answer, grading_rules)
        obj.question_id = question_id
        return obj
      rescue NameError => e
        raise AutoGrader::NoSuchGraderError, "Can't find grading strategy for #{grader}"
      end
    end
  end

  def normalized_score(max=100)
    raw_max.zero? ? 0 : (max.to_f * raw_score/raw_max).ceil
  end


  def grade!
    # default method does nothing and leaves a score of 0
  end

  private

  def self.class_init
    Dir["lib/graders/*_grader.rb"].each { |file| load file }
  end
  
  # not to be used externally
  def initialize(question_id)
    @raw_max = @raw_score = 0
    @comments = 'You did not submit any answer.'
    @question_id = question_id
    @errors = nil
  end

end

