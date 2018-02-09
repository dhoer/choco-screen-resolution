import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.net.MalformedURLException;
import java.net.URL;

import static org.junit.Assert.*;

public class ScreenResolutionTest {

  private WebDriver driver;
  private String screenResolution;

  @BeforeTest
  public void beforeTest() throws MalformedURLException {
    DesiredCapabilities capabilities = new DesiredCapabilities();
    capabilities.setBrowserName("chrome");

    String screenWidth = System.getenv("SCREEN_WIDTH");
    if (screenWidth ==  null) {
      screenWidth = "1366";
    }
    String screenHeight = System.getenv("SCREEN_HEIGHT");
    if (screenHeight ==  null) {
      screenHeight = "768";
    }
    screenResolution = String.format("%s x %s", screenWidth, screenHeight);

    String seleniumUrl = System.getenv("SELENIUM_URL");
    if (seleniumUrl ==  null) {
      seleniumUrl = "http://localhost:4444/wd/hub";
    }
    driver = new RemoteWebDriver(new URL(seleniumUrl), capabilities);
    driver.get("http://www.whatismyscreenresolution.com/");
  }

  @Test
  public void main() {
    WebElement element = driver.findElement(By.id("resolutionNumber"));
    assertEquals(screenResolution, element.getText());
  }

  @AfterTest
  public void afterTest() {
    driver.quit();
  }
}
