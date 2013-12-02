Feature: Feedback for Students
  As a student
  I would like to know how well I did on my assignment
  So I want to see a report on my grade and any penalties incurred

  Scenario: correctly report no credit period
    Given a configuration file with a grace period of "1" day and a late period of "3" days and an assignment date of "October 10th 2013"
    And a student submits an assignment on "October 15th 2013" and gets a "no credit" period message

  Scenario: correctly reports grace period
    Given a configuration file with a grace period of "1" day and a late period of "2" days and an assignment date of "October 10th 2013"
    And a student submits an assignment on "October 11th 2013" and gets a "grace" period message

  Scenario: correctly reports late period
    Given a configuration file with a grace period of "1" day and a late period of "2" days and an assignment date of "October 10th 2013"
    And a student submits an assignment on "October 12th 2013" and gets a "late" period message


