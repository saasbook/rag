Feature: Autograder grades Sinatra Hangperson assignment
  As an instructor
  So that I can give feedback to my students on their code responses
  I want to be able to create a code submission page in edX and grade it using rag

#  Background:
#    Given the submissions directory has been cleared
#    Given I've hacked the grader to have a short timeout

  @require_net_connect
  Scenario: student submits a Sinatra HerokuGrader homework
    Given I set up a test that requires internet connection
    And an XQueue that has submission "heroku_sinatra_xqueue.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "100" for my assignment
