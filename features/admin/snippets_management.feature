Feature: Managing snippets
  In order to remove the repetition of entering the same content 
  multiple times and allow applying the same block to small pieces of
  content, as a content editor I want to manage a collection of snippets
  
  Background:
    Given I am logged in as 'existing'
  
  Scenario: List snippets
    When I follow 'Snippets'
    Then I should see 'first'
    And I should see 'another'
    And I should see 'markdown'
    # And a host of others
  
  Scenario: Create a snippet
    When I follow 'Snippets'
    And I follow 'New Snippet'
    And I fill in "Name" with "Mine"
    And I fill in "Body" with "My snippet"
    And I press "Create Snippet"
    Then I should see "saved"
    And I should see "Mine"
    
  Scenario: Display form errors
    When I follow 'Snippets'
    And I follow 'New Snippet'
    And I fill in "Body" with "My snippet"
    And I press "Create Snippet"
    Then I should see an error message
    And I should see the form
  
  Scenario: Continue editing
    When I follow 'Snippets'
    And I follow 'New Snippet'
    And I fill in "Name" with "Mine"
    And I fill in "Body" with "My snippet"
    And I press "Save and Continue Editing"
    Then I should see "saved"
    And I should see the form
    
  Scenario: Delete a snippet with confirmation
    When I follow 'Snippets'
    And I follow 'Remove'
    Then I should see 'permanently remove'
    And I should see 'another'
    When I press 'Delete Snippet'
    Then I should see 'has been deleted'
    And I should see 'first'
    