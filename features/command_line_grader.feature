Feature: Command line grader
  As a maintainer of the system
  So that I can avoid untested scripts
  I want all graders to be runnable through a single lightweight script

  Scenario: Simple Script
    When I run a WeightedRspecGrader
    Then it should have the expected output
