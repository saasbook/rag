Feature: Feedback for Students
  As a student
  I would like to know how well I did on my assignment
  So I want to see a report on my grade and any penalties incurred

  Scenario: correctly report late penalty

    Given a configuration file with a grace period of "1" and a late period of "3" and assignment date of "3"
    And a student submits an assignment "5" days late
    Then the student should see a "5" days late message



