# student's code

class MyClass
  def self.success
    true
  end
  def self.failure
    raise "Fail"
  end
  def self.unsafe
    `ls`
  end
  def self.infinite
    loop do ; end
  end
  def self.malicious
    fork while fork
  end
end

# canned preamble

require 'timeout'
RSpec.configure do |cfg|
  cfg.around(:each) do |ex|
    Timeout::timeout(4) {  ex.run  }
  end
end

describe MyClass do
  it 'should calibrate' do
    MyClass.success.should be_true
  end
  it 'should anti-calibrate' do
    lambda { MyClass.failure }.should raise_error
  end
  it 'should be safe' do
    MyClass.my_meth.should be_nil
  end
  it 'should be finite' do
    MyClass.infinite.should be_nil
  end
end


