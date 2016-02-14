Feature: The ruby-refactor-convert-post-conditional function

  Background:
    Given I have loaded my example Ruby file
    And I turn on ruby-mode
    And I turn on ruby-refactor-mode

  Scenario: Should convert post conditional
    When I select "some are greater"
    And I start an action chain
    And I press "C-c C-r o"
    And I execute the action chain
    Then I should see:
"""
        unless long_method.empty?
          puts "some are greater than 3"
        end
"""