Feature: test dangerous code

  As a course instructor
  So that I can grade thousands and thousands of programming hw's efficiently
  I want to fail safely when dangerous code is submitted

Scenario Outline: kinds of dangerous code
  # this functionality not supported yet

  Given a submission containing "<dangerous_code>"
  When I run the generic RSpec grader
  Then the message should match /Score out of 100: 0/
  And the "rspec comments" section should contain "<comment>"

  Examples:
    | dangerous_code           | comment                    |
    #| loop do ; end            | execution expired          |
   # | File.open('/etc/passwd') | unsafe operation attempted |
   # | # fork while fork        | unsafe operation attempted |
