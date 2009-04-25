Feature: Serving pages from front-end
  In order to view the website content efficiently
  a visitor
  wants to load pages with caching enhancements

  Background:
    Given the page cache is clear

  Scenario: Basic page rendering
    When I go to page '/first'
    Then I should get a 200 response code
    And I should see 'First body.'

  Scenario: Rendering deeply nested page
    When I go to page '/parent/child/grandchild/great-grandchild'
    Then I should get a 200 response code
    And I should see 'Great Grandchild body.'

  Scenario: Rendering cached page with ETag
    When I go to page '/first'
    And I go to page '/first' sending the ETag
    Then I should get a 304 response code
    And I should get the same ETag header