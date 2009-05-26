Feature: Importing a repository
  In order to have control over his deployments
  A developer will import a remote repository
  So that his vendor code is protected from inadvertent upstream changes

  Scenario: Importing into an existing repository
    Given a project
    And a vendor project named 'libcalc'
    When I run 'gip import __libcalc__ vendor/libcalc'
    Then I should see "Imported __libcalc__ into vendor/libcalc"
    And the file '.gipinfo' should contain 'vendor/libcalc,__libcalc__'
    And the working copy should be clean
