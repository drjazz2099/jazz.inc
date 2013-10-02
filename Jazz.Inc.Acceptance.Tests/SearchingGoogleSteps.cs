using System;
using System.Threading;
using NUnit.Framework;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.IE;
using TechTalk.SpecFlow;

namespace Jazz.Inc.Acceptance.Tests
{
    [Binding]
    public class SearchingGoogleSteps
    {

        private InternetExplorerDriver _driver;

        [BeforeScenario("chrome")]
        public void BeforeEachTest()
        {
            _driver = new InternetExplorerDriver();
        }
        [AfterScenario("chrome")]
        public void AfterEachTest()
        {
            _driver.Quit();
        }

        [Given(@"I am on ""(.*)""")]
        public void GivenIAmOn(string websiteName)
        {
            _driver.Navigate().GoToUrl(websiteName);

        }

        [When(@"I search for ""(.*)""")]
        public void WhenISearchFor(string searchTerm)
        {
            IWebElement query = _driver.FindElement(By.Name("q"));
            query.SendKeys(searchTerm);
            query.Submit();
        }

        [Then(@"the results from the search should contain ""(.*)""")]
        public void ThenTheResultsFromTheSearchShouldContain(string expectedResult)
        {
            Thread.Sleep(1000);
            Assert.That(_driver.PageSource.Contains(expectedResult));
        }

    }
}
