Feature: The ruby-refactor-extract-to_let function
  
  Background:
    Given I have loaded my example Ruby file
    And I turn on ruby-mode
    And I turn on inf-ruby-minor-mode
    And I turn on ruby-refactor-mode

  Scenario: Should not strip trailing parenthesis
    When I select:
"""
      mock_advertiser_one = mock_model(Advertiser)
      mock_advertiser_one.stub(:uid).and_return("UID1")
"""
    And I start an action chain
    And I press "C-c C-r l"
    And I type "the_new_method"
    And I execute the action chain
    Then I should see:
"""
  let :mock_advertiser_one do
    mock_advertiser_one = mock_model(Advertiser)
    mock_advertiser_one.stub(:uid).and_return("UID1")
    mock_advertiser_one
  end
"""

  
