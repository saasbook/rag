Feature: Pulls code submissions from XQueue and grades them using information supplied from grader_payload and submits the graded response back to the XQueue
  As an instructor
  So that I can give feedback to my students on their code responses
  I want to be able to create a code submission page in edX and grade it using rag

  Background: The fake XQueue is set up and the autograder is configured. 
  Scenario Outline: autograder is configured to mocked queue and pulls submission and submits response

    Given a simple ruby submission containing "<buggy_code>"
    When I run the ruby intro grader for "HW0-1"
    And the "rspec comments" section should contain "<comment>"
    And the "rspec comments" section should contain "<expected>"
    And the "rspec comments" section should contain "<got>"

  Examples:
    | buggy_code             | comment                                      | expected | got |
    | def sum(array); 0; end | Failure/Error: sum([1,2,3,4,5]).should == 15 |  expected: 15 | got: 0 (using ==)       |