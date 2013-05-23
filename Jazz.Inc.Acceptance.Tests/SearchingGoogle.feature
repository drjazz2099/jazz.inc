Feature: SearchingGoogle
	In order to avoid silly mistakes
	As a math idiot
	I want to be told the sum of two numbers

@chrome
Scenario: Searching Google
	Given I am on "http://www.google.co.uk"
	When I search for "ERNI"
	Then the results from the search should contain "ERNI"

