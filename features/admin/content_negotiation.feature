Feature: Proper content negotiation
  In order to have a more rich and flexible editing and browsing experience
  a content editor
  wants to access the admin section with multiple content formats

  Scenario: Default to HTML format
    Given I am logged in as 'admin'
    When I send an 'Accept' header of 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-ms-application, application/vnd.ms-xpsdocument, application/xaml+xml, application/x-ms-xbap, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*'
    And I go to '/admin/pages'
    Then I should not see 'Missing template'
    
  Scenario: Requesting XML format via file-extension
    Given I am logged in as 'admin'
    When I send an 'Accept' header of 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-ms-application, application/vnd.ms-xpsdocument, application/xaml+xml, application/x-ms-xbap, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*'
    And I go to '/admin/pages.xml'
    Then I should see '<\?xml'

  Scenario: Requesting children via Ajax
    Given I am logged in as 'admin'
    When I send an 'Accept' header of 'text/javascript, text/html, application/xml, text/xml, */*'
    And I send an 'X-Requested-With' header of 'XMLHttpRequest'
    And I request the children of page 'home'
    Then I should not see 'Radiant CMS'
    And I should see '<tr'