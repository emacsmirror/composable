Feature: composable
  In order to efficiently edit text
  As an Emacs user
  I want composable editing

  Scenario: Delete to end of line
    Given the buffer is empty
    When I insert "foo bar"
    And I place the cursor after "foo"
    And I press "C-w e"
    Then I should see "foo"

  Scenario: C-w with active region
    Given the buffer is empty
    When I insert "foo bar"
    And I select " bar"
    And I press "C-w"
    Then I should see "foo"

Feature: Do Some things
  In order to do something
  As a user
  I want to do something

  Scenario: Do Something
    Given I have "something"
    When I have "something"
    Then I should have "something"
    And I should have "something"
    But I should not have "something"
