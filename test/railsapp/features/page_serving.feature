Feature: Serving pages from front-end
  In order to view the website content efficiently
  a visitor
  wants to load pages with caching enhancements

  Background:
    Given the page cache is clear

  Scenario: Basic page rendering
    When I go to the first page
    Then I should get a 200 response code
    And I should see "First body."

  Scenario: Rendering deeply nested page
    When I go to the great-grandchild page
    Then I should get a 200 response code
    And I should see "Great Grandchild body."
  
  Scenario: Apache/lighttpd acceleration
    Given I have turned on X-Sendfile headers
    When I go to the first page
    And I go to the first page
    Then I should get an "X-Sendfile" header in the response
    
  Scenario: nginx acceleration
    Given I have turned on X-Accel-Redirect headers
    When I go to the first page
    And I go to the first page
    Then I should get an "X-Accel-Redirect" header in the response
    
  Scenario: page caching enabled
    Given I have page caching on
    When I go to the first page
    Then I should get an "ETag" header in the response
    And The "Cache-Control" header should be "public"

  Scenario: page caching disabled
    Given I have page caching off
    When I go to the first page
    Then I should not get an "ETag" header in the response
    And The "Cache-Control" header should be "private"

