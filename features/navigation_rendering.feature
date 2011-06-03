Feature: Rendering the navigation tag
  In order to render the website content properly
  the system
  should parse radius tags

  Scenario: Basic navigation rendering
    Given I am logged in as "designer"
    When I go to layouts
    And I follow "Main"
    And I fill in the "layout_content" content with the text
    """
    <r:navigation urls="First: /first | Another: /another | Parent: /parent">
      <r:normal><a href="<r:path />"><r:title /></a></r:normal>
      <r:here><strong><r:title /></strong></r:here>
      <r:selected><strong><a href="<r:path />"><r:title /></a></strong></r:selected>
      <r:between> | </r:between>
    </r:navigation>
    """
    And I press "Save Changes"
    And I follow "Logout"
    And I go to "/"
    Then the page should render
    """
    <a href="/first">First</a> | <a href="/another">Another</a> | <a href="/parent">Parent</a>
    """
    And I go to "/first"
    Then the page should render
    """
    <strong>First</strong> | <a href="/another">Another</a> | <a href="/parent">Parent</a>
    """