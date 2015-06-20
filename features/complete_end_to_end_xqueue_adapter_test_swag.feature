Feature: Pulls code submissions from XQueue and grades them using information supplied from grader_payload and submits the graded response back to the XQueue
  As an instructor
  So that I can give feedback to my students on their code responses
  I want to be able to create a code submission page in edX and grade it using rag


  Scenario: autograder is configured to mocked queue and pulls submission and submits response
    Given an XQueue that has submission "submission.json" in queue
    And has been setup with the config file "config.yml"
    Then I should recieve a grade for my assignment 
