require_relative 'rag_logger'

require 'base64'
require 'json'
class CourseraSubmission
  # sid that corresponds to an assignment part on Coursera
  attr_accessor :assignment_part_sid
  # login email address of submitter
  attr_accessor :email_address
  # text contents of submission
  attr_accessor :submission
  # optional auxiliary text
  attr_accessor :submission_aux

  def initialize(assignment_part_sid, email_address, submission, 
                 submission_aux="")
    @assignment_part_sid = assignment_part_sid
    @email_address = email_address
    @submission = submission
    @submission_aux = submission_aux
  end

  def self.load_from_base64(base64_text)
    attrs = JSON.parse(Base64.strict_decode64(base64_text))
    assignment_part_sid = Base64.strict_decode64(attrs['assignment_part_sid'])
    email_address = Base64.strict_decode64(attrs['email_address'])
    submission = Base64.strict_decode64(attrs['submission'])
    submission_aux = Base64.strict_decode64(attrs['submission_aux'])
    self.new(assignment_part_sid, email_address, submission, submission_aux)
  end

  def to_json
    obj = {
      :assignment_part_sid => Base64.strict_encode64(@assignment_part_sid),
      :email_address => Base64.strict_encode64(@email_address),
      :submission => Base64.strict_encode64(@submission),
      :submission_aux => Base64.strict_encode64(@submission_aux),
    }
    obj.to_json
  end
end

