Feature: Feature Grader
  As an instructor
  So that I can check that my students are writing good cucumber test
  I want to mutation test their cucumber code

Scenario Outline: Simple Mutation Test
  Given a simple cucumber submission containing "<cucumber_code>" grade it with mutation file "hwz.yml"

  #TODO: Rework these examples to support more than one comment/expectation/got per example of code
  Examples:
    | cucumber_code                     | comment                                      | expected      | got               |
    | features.tar.gz    | Failure/Error: sum([1,2,3,4,5]).should == 15 |  expected: 15 | got: 0 (using ==) |
