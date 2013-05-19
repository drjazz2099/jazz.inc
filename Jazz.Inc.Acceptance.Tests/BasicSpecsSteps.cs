using System;
using TechTalk.SpecFlow;

namespace Jazz.Inc.Acceptance.Tests
{
    [Binding]
    public class BasicSpecsSteps
    {
        [Given(@"I am on the internet")]
        public void GivenIAmOnTheInternet()
        {
        }
        
        [When(@"I vist the Jazz Inc website")]
        public void WhenIVistTheJazzIncWebsite()
        {
        }
        
        [Then(@"I should see the correct company name")]
        public void ThenIShouldSeeTheCorrectCompanyName()
        {
        }
    }
}
