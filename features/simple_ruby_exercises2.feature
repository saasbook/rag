Feature: test dangerous code

  As a course instructor
  So that I can grade thousands and thousands of programming hw's efficiently
  I want to fail safely when dangerous code is submitted

  Scenario Outline: kinds of dangerous code

    Given a simple ruby submission containing "<buggy_code>"
    When I run the ruby intro grader for "HW0-1"
    And the "rspec comments" section should contain "<comment>"

  Examples:
    | buggy_code         | comment                    |
    | def sum(array); 0; end | Failure/Error: sum([1,2,3,4,5]).should == 15 |
