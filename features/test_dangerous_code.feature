Feature: test dangerous code

  As a course instructor
  So that I can grade thousands and thousands of programming hw's efficiently
  I want to fail safely when dangerous code is submitted

Scenario: code with infinite loop

  Given a submission containing "loop do ; end"
  When I run the generic RSpec grader
  Then the message should match /Score out of 100: 0/
  And the "rspec comments" section should contain "execution expired"


Scenario: code that tries to exhaust resources

Scenario: code that tries to do system operations
