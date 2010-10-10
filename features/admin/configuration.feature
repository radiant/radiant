Feature: Rich configuration
  In order to control site delivery
  an administrator
  wants to change the configuration of the site
  
  Background:
    Given I am logged in as "admin"
    And I go to the "configuration" admin page

  Scenario: Reviewing configuration
    Then I should see a "Site configuration" heading
		And I should see "Site title"
		And I should see "Site domain"
		And I should see the site title
		And I should see the site domain    
		
  Scenario: Editing configuration
		When I press "Edit settings"
		Then I should see a "Configuration" heading
		And I should see "Site title"
		And I should see "Timezone name"
		When I fill in "Site title" with "Something else"
		And I select "London" from "Timezone name"
		And I press "Save Changes"
		Then I should see "Site configuration"
		And I should see "Something Else"
		
