require "escaper"
describe "escapes_submissions" do
  it "Should not raise an error for empty strings" do
    lambda{escape_all_fields("")}.should_not raise_error
  end

  it "Should return the same number of fields as the original string" do
    string_1 = "file_name admin password"
    string_2 = "file_name admin password junk"

    string_1.split.length.should eq(escape_all_fields(string_1).split.length)
    string_2.split.length.should eq(escape_all_fields(string_2).split.length)
  end

  it "Should wrap each string in quotes" do

    unescaped_str = "This is unescaped"
    escaped_str = escape_all_fields(unescaped_str)
    escaped_str.split.each do |field|
      field.should match /^\"[^\"]*\"$/
    end 
  end   

end
