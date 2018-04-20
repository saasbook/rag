Feature: Mutation Grader
  As an instructor
  So that I can check students tests are not vacuous
  I want to be mutate the underlying code and check for expected failures

  Scenario: student submits a HW3
    Given an XQueue that has submission "hw3_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "100" for my assignment

  Scenario: student submits a HW3 from An Ju
    Given an XQueue that has submission "hw3_anju_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "100" for my assignment

  Scenario: student submits a HW3 that fails from An Ju
    Given an XQueue that has submission "hw3_anju_fail_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "100" for my assignment

  Scenario: student submits a HW3 that gets stuck
    Given an XQueue that has submission "hw3_stuck_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0" for my assignment
    And results should include "unknown attribute 'released_date' for Movie. (ActiveRecord::UnknownAttributeError)"
  
  Scenario: student submits a bdd cucumber assignment that completely derails the grader
    Given an XQueue that has submission "bdd_cucumber_derailed_submission.json" in queue
    And has been setup with the config file "conf.yml"
    Then I should receive a grade of "0" for my assignment
    And results should include "There was a fatal error with your submission. It either timed out or caused an exception"
