Feature: Pulls code submissions from XQueue and grades them using information supplied from grader_payload and submits the graded response back to the XQueue
  As an instructor
  So that I can give feedback to my students on their code responses
  I want to be able to create a code submission page in edX and grade it using rag


  Scenario: student submits a correct hw1 submission on edXs
    Given an XQueue that has submission "hw1_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade for my assignment 

  @wip
  Scenario: student submits a heroku deployment on edX
    Given an XQueue that has submission "hw2_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade for my assignment
