Feature: Managing pages
  In order to create, modify, and delete content from the website
  a content editor
  wants to manipulate pages in the admin interface
  
  Scenario: Listing pages
    Given I am logged in as "existing"
    When I go to the "pages" admin page
    Then I should see "Pages"
    And I should see "Home"
    
  Scenario: No pages
    Given I am logged in as "existing"
    Given there are no pages
    When I go to the "pages" admin page
    Then I should see "No Pages"
    
  Scenario: Creating a homepage
    Given I am logged in as "existing"
    Given there are no pages
    When I go to the "pages" admin page
    And I follow "New Homepage"
    Then I should see "New Page"
    And there should be a "body" part
    And there should be an "extended" part
    When I fill in "Page Title" with "My site"
    And I fill in "Slug" with "/"
    And I fill in "Breadcrumb" with "My site"
    And I fill in the "body" content with "Under Construction"
    And I fill in the "extended" content with "foobar"
    And I select "Published" from "Status"
    And I press "Create page"
    Then I should be on the sitemap
    And I should see "My site"
    When I go to the homepage
    Then I should see "Under Construction"
  
  Scenario: Creating child pages
    Given I am logged in as "existing"
    And there is a homepage
    When I go to the "pages" admin page
    And I follow "Add child"
    Then I should see "New Page"
    And there should be a "body" part
    And there should be an "extended" part
    When I fill in "Page Title" with "My child"
    And I fill in "Slug" with "my-child"
    And I fill in "Breadcrumb" with "My child"
    And I fill in the "body" content with "Under Construction"
    And I fill in the "extended" content with "foobar"
    And I select "Published" from "Status"
    And I press "Save and Continue Editing"
    Then I should see "Edit Page"
    And I should see "Under Construction"
    When I go to the new child page
    Then I should see "Under Construction"
    
  Scenario: Delete page
    Given I am logged in as "existing"
    When I go to the "pages" admin page
    And I follow "remove page"
    Then I should see "permanently remove"
    When I press "Delete Pages"
    Then I should see "No Pages"
    
  Scenario: View a page
    Given I am logged in as "existing"
    When I view a page
    Then I should see "Edit Page"
    
  Scenario: Change page type
    Given I am logged in as "existing"
    When I edit the "virtual" page
    And I select "<normal>" from "Page type"
    And I press "Save and Continue Editing"
    Then I should see "Edit Page"
    And "&lt;normal&gt;" should be selected for "Page type"