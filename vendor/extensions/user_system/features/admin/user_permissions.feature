Feature: User authentication and permissions
  In order to protect design assets from unskilled modification
    and user accounts from hijacking
  users should be given different access permissions
  
  Scenario Outline: Authentication-login
  When I go to the login page
    And I fill in "Username" with "<username>"
    And I fill in "Password" with "password"
    And I press "Login"
    Then I should see "Pages"
    
    Examples:
      | username  |
      | admin     |
      | existing  |
      | designer |
  
  Scenario Outline: Authentication-logout
    Given I am logged in as "<username>"
    When I follow "Logout"
    Then I should be on the login screen
    
    Examples:
      | username  |
      | admin     |
      | existing  |
      | designer |
  
  
  Scenario Outline: All users can edit pages
    Given I am logged in as "<username>"
    And I should see "Pages"
    When I go to the "pages" admin page
    And I follow "Home"
    Then I should see "Edit Page"
    And I should see "Pages"
    
    Examples:
      | username  |
      | admin     |
      | existing  |
      | designer |
      
  Scenario Outline: Admins and designers can see and edit snippets
    Given I am logged in as "<username>"
    And I should see "Design"
    When I follow "Design" within "#navigation"
    And I follow "Snippets"
    And I should not see "You must have designer privileges"
    And I follow "first"
    Then I should see "Edit Snippet"
    
    Examples:
      | username  |
      | admin     |
      | designer |
  
  Scenario Outline: Admins and designers can see and edit layouts
    Given I am logged in as "<username>"
    And I should see "Design"
    When I follow "Design" within "#navigation"
    And I follow "Layouts"
    And I should not see "You must have designer privileges"
    And I follow "Main"
    Then I should see "Edit Layout"
    
    Examples:
      | username  |
      | admin     |
      | designer |
      
  Scenario Outline: Ordinary users cannot edit layouts
    Given I am logged in as "<username>"
    And I should not see "Design"
    When I go to the "layouts" admin page
    Then I should see "You must have designer privileges"

    Examples:
      | username  |
      | existing  |
      | another   |
  
  Scenario Outline: Ordinary users cannot edit snippets
    Given I am logged in as "<username>"
    And I should not see "Design"
    When I go to the "snippets" admin page
    Then I should see "You must have designer privileges"

    Examples:
      | username  |
      | existing  |
      | another   |
    
  Scenario: Admins can see and edit users
    Given I am logged in as "admin"
    When I follow "Settings"
    And I follow "Users"
    And I should not see "You must have administrative privileges"
    And I follow "Another"
    Then I should see "Edit User"
  
  Scenario Outline: Non-admins cannot see or edit users
    Given I am logged in as "<username>"
    And I should not see "Users"
    When I go to the "users" admin page
    Then I should see "You must have administrative privileges"

    Examples:
      | username  |
      | existing  |
      | another   |
      | designer |
      
  Scenario Outline: Non-admins see preferences link
    Given I am logged in as "<username>"
    And I should see "Settings"
    When I follow "Settings"
    And I follow "Personal"
    Then I should see "Personal Preferences"
    
    Examples:
      | username  |
      | existing  |
      | another   |
      | designer |

  Scenario: Admin users can see extensions
    Given I am logged in as "admin"
    When I follow "Settings"
    And I follow "Extensions"
    Then I should see "Archive"
  
  Scenario Outline: Non-admin users cannot see extensions
    Given I am logged in as "<username>"
    When I follow "Settings"
    And I should not see "Extensions"
    When I go to the "extensions" admin page
    Then I should see "You must have administrative privileges"

    Examples:
      | username  |
      | existing  |
      | another   |
      | designer |
  
  Scenario Outline: Anyone can export YAML
    Given I am logged in as "<username>"
    When I go to the export page
    Then I should see "id:"
    
    Examples:
      | username  |
      | admin     |
      | existing  |
      | another   |
      | designer |