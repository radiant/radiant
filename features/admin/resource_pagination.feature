Feature: Paginating admin views
  In order to reduce load time and page bulk
  a content editor
  wants longer resource lists to be paginated 
  
  Background:
    Given There are many snippets
    And I am logged in as "designer"
    And I go to the "snippets" admin page

  Scenario: More snippets than we want to show on one page
    Then I should see "first"
    And I should not see "snippet_50"
    And I should see page 1 of the results
    And I should see pagination controls
    And I should see a depagination link

    When I follow "2" within "div.pagination"
    Then I should see page 2 of the results
    And I should see "snippet_50"

    When I follow "show all" within "div.depaginate"
    # Then I should mention the request parameters
    Then I should see all the snippets
    And I should not see pagination controls
    And I should not see a depagination link
    