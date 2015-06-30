@wip
Feature: Test Simple Ruby Code

  As a beginning rubyist
  So that I can improve my ruby skills 
  I want to receive feedback on my errors

  Scenario: check buggy code in HW0-1 -- part1
    Given a simple ruby submission containing "def sum(array); 0; end"
    When I run the ruby intro grader for "HW0-1"
    And the "rspec comments" section should contain "Failure/Error: sum([1,2,3,4,5]).should == 15"
    And the "rspec comments" section should contain "expected: 15"
    And the "rspec comments" section should contain "got: 0 (using ==)"

  Scenario: check buggy code in HW0-1 -- part2a
    Given a simple ruby submission containing "def max_2_sum(array); 0; end"
    When I run the ruby intro grader for "HW0-1"
    And the "rspec comments" section should contain "Failure/Error: max_2_sum([1,-2,-3,-4,-5]).should == -1"
    And the "rspec comments" section should contain "expected: -1"
    And the "rspec comments" section should contain "got: 0 (using ==)"

    Scenario: check buggy code in HW0-1 -- part2b
      Given a simple ruby submission containing "def max_2_sum(array); 0; end"
      When I run the ruby intro grader for "HW0-1"
      And the "rspec comments" section should contain "Failure/Error: max_2_sum([1,2,3,3]).should == 6"
      And the "rspec comments" section should contain "expected: 6"
      And the "rspec comments" section should contain "got: 0 (using ==)"

    Scenario: check buggy code in HW0-1 -- part2c
      Given a simple ruby submission containing "def max_2_sum(array); 0; end"
      When I run the ruby intro grader for "HW0-1"
      And the "rspec comments" section should contain "Failure/Error: max_2_sum([3]).should == 3"
      And the "rspec comments" section should contain "expected: 3"
      And the "rspec comments" section should contain "got: 0 (using ==)"
    @wip
    Scenario: check buggy code in HW0-1 -- part3a
      Given a simple ruby submission containing "def sum_to_n?(array, p); false; end"
      When I run the ruby intro grader for "HW0-1"
      And the "rspec comments" section should contain "Failure/Error: sum_to_n?([1,2,3,4,5], 5).should be_true"
      And the "rspec comments" section should contain "expected: true value"
      And the "rspec comments" section should contain "got: false"

    Scenario: check buggy code in HW0-1 -- part3b
      Given a simple ruby submission containing "def sum_to_n?(array, p); false; end"
      When I run the ruby intro grader for "HW0-1"
      And the "rspec comments" section should contain "Failure/Error: sum_to_n?([], 0).should be_true"
      And the "rspec comments" section should contain "expected: true value"
      And the "rspec comments" section should contain "got: false"

    Scenario: check buggy code in Hw0-2 -- part1
      Given a simple ruby submission containing "def hello(name); name; end"
      When I run the ruby intro grader for "HW0-2"
      And the "rspec comments" section should contain "Failure/Error: hello("Dan").should eq('Hello, Dan'), "Incorrect results for input: \"Dan\"""
      And the "rspec comments" section should contain ""
      And the "rspec comments" section should contain ""

    Scenario: check buggy code in Hw0-2 -- part2
      Given a simple ruby submission containing "def starts_with_consonant?(s); false; end"
      When I run the ruby intro grader for "HW0-2"
      And the "rspec comments" section should contain "Failure/Error: starts_with_consonant?("Veeeeeeee").should be_true, "Incorrect results for input: \"Veeeeeeee\"""
      And the "rspec comments" section should contain ""
      And the "rspec comments" section should contain ""

    Scenario: check buggy code in Hw0-2 -- part3
      Given a simple ruby submission containing "def binary_multiple_of_4?(s); false end"
      When I run the ruby intro grader for "HW0-2"
      And the "rspec comments" section should contain "Failure/Error: binary_multiple_of_4?("1010101010100").should be_true, "Incorrect results for input: \"1010101010100\"""
      And the "rspec comments" section should contain ""
      And the "rspec comments" section should contain ""

    Scenario: check buggy code in Hw0-3 -- part1

      Given a simple ruby submission containing "class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end"
      When I run the ruby intro grader for "HW0-3"
      And the "rspec comments" section should contain "Failure/Error: @book.isbn.should == 'isbn1'"
      And the "rspec comments" section should contain ""
      And the "rspec comments" section should contain ""

    Scenario: check buggy code in Hw0-3 -- part2

      Given a simple ruby submission containing "class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end"
      When I run the ruby intro grader for "HW0-3"
      And the "rspec comments" section should contain "Failure/Error: @book.price.should == 33.8"
      And the "rspec comments" section should contain ""
      And the "rspec comments" section should contain ""

    Scenario: check buggy code in Hw0-3 -- part3

      Given a simple ruby submission containing "class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end"
      When I run the ruby intro grader for "HW0-3"
      And the "rspec comments" section should contain "Failure/Error: @book.isbn = 'isbn2'"
      And the "rspec comments" section should contain ""
      And the "rspec comments" section should contain ""


    Scenario: check buggy code in Hw0-3 -- part4

      Given a simple ruby submission containing "class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end"
      When I run the ruby intro grader for "HW0-3"
      And the "rspec comments" section should contain "Failure/Error: @book.price = 300.0"
      And the "rspec comments" section should contain ""
      And the "rspec comments" section should contain ""

    Scenario: check buggy code in Hw0-3 -- part5

      Given a simple ruby submission containing "class BookInStock; def initialize(isbn, price); @isbn = isbn; @price = price; end; def price_as_string; @price; end; end"
      When I run the ruby intro grader for "HW0-3"
      And the "rspec comments" section should contain "Failure/Error: BookInStock.new('isbn11', 1.1).price_as_string.should == '$1.10'"
      And the "rspec comments" section should contain "expected: "$1.10""
      And the "rspec comments" section should contain "got: 1.1 (using ==)"
