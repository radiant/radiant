Feature: Edit user preferences
  In order to keep my credentials secure and information up-to-date
  As a user I want to update my preferences
  
  Scenario Outline: Edit preferences
    Given I am logged in as "<username>"
    When I follow "Preferences"
    And I fill in "E-mail" with "my-new-email@example.com"
    And I press "Save Changes"
    Then I should see "updated"
    And I should see "Home"
    
    Examples:
      | username  |
      | another   |
      | existing  |
      | developer |
      | non_admin |