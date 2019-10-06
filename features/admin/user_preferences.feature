Feature: Edit user preferences
  In order to keep my credentials secure and information up-to-date
  As a user I want to update my preferences
  
  Scenario Outline: Edit preferences
    Given I am logged in as "<username>"
    When I open my preferences
    And I fill in "E-mail Address" with "my-new-email@example.com"
    And I press "Save Changes"
    Then I should be on the configuration screen
    
    Examples:
      | username  |
      | admin     |
      | another   |
      | existing  |
      | designer  |
      | non_admin |
  
  Scenario Outline: Save invalid preferences
    Given I am logged in as "<username>"
    When I open my preferences
    And I fill in "Username" with ""
    And I press "Save Changes"
    Then I should be on the preferences screen
    And I should see "this must not be blank"
    And I should see "Personal"
    
    Examples:
      | username  |
      | admin     |
      | another   |
      | existing  |
      | designer  |
      | non_admin |