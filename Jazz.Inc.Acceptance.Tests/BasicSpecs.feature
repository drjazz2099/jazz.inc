Feature: Jazz Inc

@jazz
Scenario: Jazz Inc should include the name Jazz
	Given I am a customer
	When I go to "http://localhost"
	Then the page should contain "Jazz"


@jazz
Scenario: Jazz Inc should include the name Jazz Inc
	Given I am a customer
	When I go to "http://localhost"
	Then the page should contain "Jazz Inc."



