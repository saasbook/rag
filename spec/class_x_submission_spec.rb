require 'class_x_submission'
require 'base64'
require 'json'
describe ClassXSubmission do
  describe '#to_json' do
    it 'should return a valid JSON object with Base64-encoded attributes' do
      id = 'my_id'
      email = 'my_email@example.com'
      submission = 'my submission'
      json = ClassXSubmission.new(id, email, submission).to_json
      result = JSON.parse(json)
      Base64.strict_decode64(result["assignment_part_sid"]).should == id
      Base64.strict_decode64(result["email_address"]).should == email
      Base64.strict_decode64(result["submission"]).should == submission
    end
  end

  describe '#load_from_base64' do
    it 'should return a valid ClassXSubmission object' do
      base64_text = 'eyJhc3NpZ25tZW50X3BhcnRfc2lkIjoiYlhsZmFXUT0iLCJlbWFpbF9hZGRyZXNzIjoiYlhsZlpXMWhhV3hBWlhoaGJYQnNaUzVqYjIwPSIsInN1Ym1pc3Npb24iOiJiWGtnYzNWaWJXbHpjMmx2Ymc9PSIsInN1Ym1pc3Npb25fYXV4IjoiIn0='

      submission = ClassXSubmission.load_from_base64(base64_text)
      submission.assignment_part_sid.should == 'my_id'
      submission.email_address.should == 'my_email@example.com'
      submission.submission.should == 'my submission'
    end
  end
end
