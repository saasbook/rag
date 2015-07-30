Feature: Pulls code submissions from XQueue and grades them using information supplied from grader_payload and submits the graded response back to the XQueue
  As an instructor
  So that I can give feedback to my students on their code responses
  I want to be able to create a code submission page in edX and grade it using rag

  Scenario: student submits a hw1 submission on edXs
    Given an XQueue that has submission "hw1_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0.3" for my assignment

  # These tests can be slow and unreliable because they rely on heroku deployments. They may be down or need to spin up.
  @require_net_connect
  Scenario: student submits a heroku deployment on edX
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw2_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "1.0" for my assignment

  #@require_net_connect
  Scenario: student submits a homework graded by HW5Grader late on edX
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw5_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0" for my assignment
  @require_net_connect
  Scenario: student submits a homework (3) graded by FeatureGrader on edX
    # Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw3_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0.4" for my assignment
