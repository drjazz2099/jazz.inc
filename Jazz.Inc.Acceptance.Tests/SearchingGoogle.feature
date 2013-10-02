Feature: SearchingGoogle
	In order to avoid silly mistakes
	As a math idiot
	I want to be told the sum of two numbers

@chrome
Scenario: Searching Google
	Given I am on "http://www.google.co.uk"
	When I search for "ERNI"
	Then the results from the search should contain "ERNI"

@chrome
Scenario: Searching Google for roche
	Given I am on "http://www.google.co.uk"
	When I search for "roche"
	Then the results from the search should contain "roche"



@chrome
Scenario: Searching Google for roche
	Given I am on "http://www.google.co.uk"
	When I search for "erni"
	Then the results from the search should contain "erni"
