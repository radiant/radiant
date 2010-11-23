Feature: Rich configuration
  In order to control site delivery
  an administrator
  wants to change the configuration of the site
  
  Background:
    Given I am logged in as "admin"
    And I go to the "configuration" admin page

  Scenario: Reviewing configuration
    Then I should see "Personal Preferences"
    And I should see "Configuration"
		And I should see "Site Name"
		And I should see "Site Domain"
		
  Scenario: Editing configuration
		When I press "Edit Configuration"
		Then I should see the form
		And I should see "Site Name"
		And I should see "Local Timezone"
		When I fill in "Site Name" with "Something else"
		And I select "London" from "Local Timezone"
		And I press "Save Changes"
    And I should see "Configuration"
		And I should see "Something else"
		
  Scenario: Editing preferences
		When I press "Edit Preferences"
    Then I should see "Personal Preferences"
		And I should see the form
