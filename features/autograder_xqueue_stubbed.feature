Feature: Autograder configured to accept student submissions from edX and grade them
  As an instructor
  So that I can give feedback to my students on their code responses
  I want to be able to create a code submission page in edX and grade it using rag

#  Background:
#    Given the submissions directory has been cleared
#    Given I've hacked the grader to have a short timeout

  # These tests can be slow and unreliable because they rely on heroku deployments; the dynos may be down or need to spin up.

  @require_net_connect
  Scenario: student submits a HerokuGrader homework
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "heroku_xqueue.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "100" for my assignment

  @require_net_connect
  Scenario: student submits a homework graded by HW5Grader late on edX
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw5_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0" for my assignment
  #@require_net_connect

  @require_net_connect
  Scenario: student submits a HW4
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw4_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "100" for my assignment

  @require_net_connect
  Scenario: student submits a HW4 that times out
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw4_stuck_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0" for my assignment
    And results should include "There was a fatal error with your submission. It either timed out or caused an exception"

  @require_net_connect
  Scenario: student submits a HW4 conceals rspec error
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw4_rspec_error.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "60" for my assignment
    And results should include "Failure/Error: expect(assigns(:movies)).to eq([movie])"

  @require_net_connect
  Scenario: student submits a HW4 with migration_error
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw4_migration_error.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0" for my assignment
    And results should include "SQLException: duplicate column name: director: ALTER TABLE"

  @require_net_connect
  Scenario: student submits a HW4 that includes factory girl
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "hw4_includes_factory_girl.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "60" for my assignment
