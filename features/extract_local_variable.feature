Feature: The ruby-refactor-extract-local-variable function
  
  Background:
    Given I have loaded my example Ruby file
    And I turn on ruby-mode
    And I turn on inf-ruby-minor-mode
    And I turn on ruby-refactor-mode

  Scenario: Should extract a local variable
    When I select "\"#{value} is greater than three\""
    And I start an action chain
    And I press "C-c C-r v"
    And I type "foo_var"
    And I execute the action chain
    Then I should see:
"""
        greater_than_three.each do |value|
          foo_var = "#{value} is greater than three"
          puts foo_var
        end
"""

