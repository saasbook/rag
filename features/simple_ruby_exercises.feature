Feature: test dangerous code

  As a course instructor
  So that I can grade thousands and thousands of programming hw's efficiently
  I want to fail safely when dangerous code is submitted

  Scenario Outline: kinds of dangerous code

    Given a simple ruby submission containing "<buggy_code>"
    When I run the ruby intro grader for "HW0-1"
    And the "rspec comments" section should contain "<comment>"
    And the "rspect comments" section should contain "<expected>"
    And the "rspect comments" section should contain "<got>"
  #TODO: Rework these examples to support more than one comment/expectation/got per example of code
  Examples:
    | buggy_code             | comment                                      | expected | got |
    | def sum(array); 0; end | Failure/Error: sum([1,2,3,4,5]).should == 15 |  expected: 15 | got: 0 (using ==)       |
    | def max_2_sum(array); 0; end |Failure/Error: max_2_sum([1,-2,-3,-4,-5]).should == -1 |expected: -1 |  got: 0 (using ==)|
    | def max_2_sum(array); 0; end |Failure/Error: max_2_sum([1,2,3,3]).should == 6| expected: 6| got: 0 (using ==)|
    | def max_2_sum(array); 0; end |Failure/Error: max_2_sum([3]).should == 3| expected: 3| got: 0 (using ==)|
    |def sum_to_n?(array, p); false; end|Failure/Error: sum_to_n?([1,2,3,4,5], 5).should be_true|  expected: true value| got: false|
    |def sum_to_n?(array, p); false; end|Failure/Error: sum_to_n?([], 0).should be_true|expected: true value| got: false|

