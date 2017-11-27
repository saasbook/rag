Feature: WRITE SOMETHING


  @require_net_connect
  Scenario: student submits a acceptance test unit test cycle assignment
    Given I set up a test that requires internet connection
    Given an XQueue that has submission "acc_unit_homepage_issue_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "60" for my assignment
    And results should not include "Welcome aboard"
