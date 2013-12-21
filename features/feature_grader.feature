Feature: Feature Grader
  As an instructor
  So that I can check that my students are writing good cucumber test
  I want to mutation test their cucumber code

Scenario Outline: Simple Mutation Test
  Given a simple cucumber submission containing a cuke "<cucumber_code>", step "<step>" grade it with mutation file "hwz.yml"

  #TODO: Rework these examples to support more than one comment/expectation/got per example of code
  Examples:
    | cucumber_code                                       | step                                  | expected          | got                    |
    | Feature: feature,Scenario: Test,Given 1 is 1        | Given /^1 is 1/ do,true,end           | expected: false   | got: true              |
