using System;
using System.Threading;
using NUnit.Framework;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;
using TechTalk.SpecFlow;

namespace Jazz.Inc.Acceptance.Tests
{
    [Binding]
    public class JazzIncSteps
    {
        private InternetExplorerDriver _driver;

        [BeforeScenario("jazz")]
        public void BeforeEachTest()
        {
            _driver = new InternetExplorerDriver();
        }
        [AfterScenario("jazz")]
        public void AfterEachTest()
        {
            _driver.Quit();
        }


        [Given(@"I am a customer")]
        public void GivenIAmACustomer()
        {
        }
        
        [When(@"I go to ""(.*)""")]
        public void WhenIGoTo(string websiteName)
        {
            _driver.Navigate().GoToUrl(websiteName); ;
        }

        [Then(@"the page should contain ""(.*)""")]
        public void ThenTheResultsFromTheSearchShouldContain(string expectedResult)
        {
            Thread.Sleep(1000);
            Assert.That(_driver.PageSource.Contains(expectedResult));
        }
    }
}
