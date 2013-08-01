Feature: The ruby-refactor-extract-constant function
  
  Background:
    Given I have loaded my example Ruby file
    And I turn on ruby-mode
    And I turn on inf-ruby-minor-mode
    And I turn on ruby-refactor-mode

  Scenario: Should extract a constant
    When I select "\"#{value} is greater than three\""
    And I start an action chain
    And I press "C-c C-r c"
    And I type "FOO_CONST"
    And I execute the action chain
    Then I should see:
"""
  module Inner
    class MyClass

      FOO_CONST = "#{value} is greater than three"

      attr_reader
"""
