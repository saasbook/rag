Feature: Autograder configured to accept student submissions from edX and grade them
  As an instructor
  So that I can give feedback to my students on their code responses
  I want to be able to create a code submission page in edX and grade it using rag



  Scenario: student submits RSpecGrader assignment containing multiple files with specs hosted on Github
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "zipped_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "1.0" for my assignment

  @require_net_connect
  Scenario: simple one file submission against one spec file RSpecGrader
    Given an XQueue that has submission "simple_rspec_xqueue.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0.3" for my assignment

  # These tests can be slow and unreliable because they rely on heroku deployments; the dynos may be down or need to spin up.

  @require_net_connect
  Scenario: student submits a HerokuGrader homework
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "heroku_xqueue.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "1.0" for my assignment

  @require_net_connect
  Scenario: student submits a homework graded by HW5Grader late on edX
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw5_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0" for my assignment
  @require_net_connect
  Scenario: student submits a HW5
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw3_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0.4" for my assignment
