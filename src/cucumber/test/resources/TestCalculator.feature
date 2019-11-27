Scenario: Adding 2 number
    Given I have 1000 and 2000
    When add two numbers
    Then it should return 3000
    
Scenario: Substract 2 number
    Given I have 2000 from 1000
    When I substruct numbers
    Then it should return -1000
