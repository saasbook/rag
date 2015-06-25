Feature: Test Simple Ruby Code

  As a beginning rubyist
  So that I can improve my ruby skills 
  I want to receive feedback on my errors

  @wip
  Scenario Outline: check buggy code in HW0-1

    Given a simple ruby submission containing "<buggy_code>"
    When I run the ruby intro grader for "HW0-1"
    And the "rspec comments" section should contain "<comment>"
    And the "rspec comments" section should contain "<expected>"
    And the "rspec comments" section should contain "<got>"
  #TODO: Rework these examples to support more than one comment/expectation/got per example of code
  Examples:
    | buggy_code             | comment                                      | expected | got |
    | def sum(array); 0; end | Failure/Error: sum([1,2,3,4,5]).should == 15 |  expected: 15 | got: 0 (using ==)       |
    | def max_2_sum(array); 0; end |Failure/Error: max_2_sum([1,-2,-3,-4,-5]).should == -1 |expected: -1 |  got: 0 (using ==)|
    | def max_2_sum(array); 0; end |Failure/Error: max_2_sum([1,2,3,3]).should == 6| expected: 6| got: 0 (using ==)|
    | def max_2_sum(array); 0; end |Failure/Error: max_2_sum([3]).should == 3| expected: 3| got: 0 (using ==)|
    |def sum_to_n?(array, p); false; end|Failure/Error: sum_to_n?([1,2,3,4,5], 5).should be_true|  expected: true value| got: false|
    |def sum_to_n?(array, p); false; end|Failure/Error: sum_to_n?([], 0).should be_true|expected: true value| got: false|

  @wip
  Scenario Outline: check buggy code in Hw0-2

    Given a simple ruby submission containing "<buggy_code>"
    When I run the ruby intro grader for "HW0-2"
    And the "rspec comments" section should contain "<comment>"
    And the "rspec comments" section should contain "<expected>"
    And the "rspec comments" section should contain "<got>"
  #TODO: Rework these examples to support more than one comment/expectation/got per example of code
  Examples:
    | buggy_code             | comment                                      | expected | got |
    | def hello(name); name; end | Failure/Error: hello("Dan").should eq('Hello, Dan'), "Incorrect results for input: \"Dan\"" |||
    | def starts_with_consonant?(s); false; end |  Failure/Error: starts_with_consonant?("Veeeeeeee").should be_true, "Incorrect results for input: \"Veeeeeeee\""|||
    | def binary_multiple_of_4?(s); false end | Failure/Error: binary_multiple_of_4?("1010101010100").should be_true, "Incorrect results for input: \"1010101010100\""|||
  
  @wip
  Scenario Outline: check buggy code in Hw0-3

    Given a simple ruby submission containing "<buggy_code>"
    When I run the ruby intro grader for "HW0-3"
    And the "rspec comments" section should contain "<comment>"
    And the "rspec comments" section should contain "<expected>"
    And the "rspec comments" section should contain "<got>"
  #TODO: Rework these examples to support more than one comment/expectation/got per example of code
  Examples:
    | buggy_code             | comment                                      | expected | got |
    |class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end|Failure/Error: @book.isbn.should == 'isbn1'|||
    |class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end|Failure/Error: @book.price.should == 33.8|||
    |class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end|Failure/Error: @book.isbn = 'isbn2'|||
    |class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end|Failure/Error: @book.price = 300.0|||
    |class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end|Failure/Error: BookInStock.new('isbn11', 1.1).price_as_string.should == '$1.10'|expected: "$1.10"|got: 1.1 (using ==)|