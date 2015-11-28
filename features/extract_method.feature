Feature: The ruby-refactor-extract-to_method function

  Background:
    Given I have loaded my example Ruby file
    And I turn on ruby-mode
    And I turn on ruby-refactor-mode

  Scenario: Extracted method should have proper indentation
    When I select "puts \"#{value} is greater than three\""
    And I start an action chain
    And I press "C-c C-r e"
    And I type "the_new_method"
    And I execute the action chain
    Then I should see:
"""
      def the_new_method
        puts "#{value} is greater than three"
      end
"""


  Scenario: Extracted method should wrap next line when the regions ends with newline
    When I select:
"""
        greater_than_three.each do |value|
          puts "#{value} is greater than three"
        end

"""
    And I start an action chain
    And I press "C-c C-r e"
    And I type "the_new_method"
    And I execute the action chain
    Then I should see:
"""

        the_new_method
      end
"""
