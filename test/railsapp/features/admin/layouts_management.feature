Feature: Managing snippets
  In order to properly display the content 
  As a designer I want to manage the layouts
  
  Background:
    Given I am logged in as "designer"
    
  Scenario: View a layout
    When I view a layout
    Then I should see "Edit Layout"