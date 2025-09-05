**

```gherkin
Feature: Secure user login with two‑factor authentication (2FA)

  As a registered user
  I want to log in using two‑factor authentication
  So that my account is protected against unauthorized access

  Background:
    Given I navigate to the login page

  # Happy path
  Scenario: Successful login with correct credentials and 2FA code
    When I enter username "john.doe@example.com"
    And I enter password "StrongPass!23"
    And I click the login button
    Then I should see the 2FA prompt
    When I enter 2FA code "123456"
    And I click the verify button
    Then I should be logged in
    And I should see the dashboard

  # Edge cases
  Scenario Outline: Login fails with incorrect credentials or 2FA
    When I enter username "<username>"
    And I enter password "<password>"
    And I click the login button
    Then I should see the 2FA prompt
    When I enter 2FA code "<code>"
    And I click the verify button
    Then I should see an error message "<error>"

    Examples:
      | username                | password          | code   | error                                 |
      | john.doe@example.com    | WrongPass!        | 123456 | Invalid credentials                    |
      | john.doe@example.com    | StrongPass!23     | 000000 | Invalid 2FA code                       |
      | john.doe@example.com    | StrongPass!23     |        | 2FA code is required                   |
      | john.doe@example.com    | StrongPass!23     | 123456 | 2FA code has expired                   |

  Scenario: Login fails when account is locked
    When I enter username "locked.user@example.com"
    And I enter password "AnyPass!23"
    And I click the login button
    Then I should see an error message "Your account is locked. Please contact support."

  Scenario: User requests a new 2FA code and logs in successfully
    When I enter username "john.doe@example.com"
    And I enter password "StrongPass!23"
    And I click the login button
    Then I should see the 2FA prompt
    When I request a new 2FA code
    And I enter 2FA code "654321"
    And I click the verify button
    Then I should be logged in
    And I should see the dashboard

  Scenario: User cancels 2FA and remains on the login page
    When I enter username "john.doe@example.com"
    And I enter password "StrongPass!23"
    And I click the login button
    Then I should see the 2FA prompt
    When I cancel 2FA
    Then I should remain on the login page
```

---

**STEP_DEFINITIONS (TypeScript / WebDriverIO):**

```ts
/* eslint-disable @typescript-eslint/no-unused-vars */
import { Given, When, Then, And, Before, After } from '@cucumber/cucumber';
import { expect } from '@wdio/globals';
import LoginPage from '../pageobjects/LoginPage';
import TwoFactorPage from '../pageobjects/TwoFactorPage';
import DashboardPage from '../pageobjects/DashboardPage';

/**
 * Background step – navigate to the login page
 */
Given('I navigate to the login page', async () => {
  await LoginPage.open();
  await expect(LoginPage).toBeDisplayed();
});

/**
 * Common steps for entering credentials
 */
When('I enter username {string}', async (username: string) => {
  await LoginPage.usernameInput.setValue(username);
});

When('I enter password {string}', async (password: string) => {
  await LoginPage.passwordInput.setValue(password);
});

When('I click the login button', async () => {
  await LoginPage.loginButton.click();
});

/**
 * 2FA prompt visibility
 */
Then('I should see the 2FA prompt', async () => {
  await expect(TwoFactorPage).toBeDisplayed();
});

/**
 * Entering the 2FA code
 */
When('I enter 2FA code {string}', async (code: string) => {
  await TwoFactorPage.codeInput.setValue(code);
});

When('I click the verify button', async () => {
  await TwoFactorPage.verifyButton.click();
});

/**
 * Successful login
 */
Then('I should be logged in', async () => {
  await expect(DashboardPage).toBeDisplayed();
});

Then('I should see the dashboard', async () => {
  await expect(DashboardPage.dashboardHeader).toBeDisplayed();
});

/**
 * Error handling
 */
Then('I should see an error message {string}', async (message: string) => {
  const errorEl = await LoginPage.errorMessage;
  await expect(errorEl).toBeDisplayed();
  await expect(errorEl).toHaveText(message);
});

/**
 * Request a new 2FA code
 */
When('I request a new 2FA code', async () => {
  await TwoFactorPage.resendButton.click();
  // Wait for the new code to be generated (mocked in tests)
  await browser.pause(500); // replace with proper wait in real tests
});

/**
 * Cancel 2FA
 */
When('I cancel 2FA', async () => {
  await TwoFactorPage.cancelButton.click();
});

/**
 * Ensure we remain on the login page after cancel
 */
Then('I should remain on the login page', async () => {
  await expect(LoginPage).toBeDisplayed();
});

/**
 * Optional hooks – clean up after each scenario
 */
After(async () => {
  // Clear session / cookies to avoid cross‑scenario contamination
  await browser.deleteCookies();
});
```

**Notes on the implementation**

1. **Page Objects** – `LoginPage`, `TwoFactorPage`, and `DashboardPage` expose the elements used in the steps (`usernameInput`, `passwordInput`, `loginButton`, `codeInput`, `verifyButton`, `resendButton`, `cancelButton`, `errorMessage`, `dashboardHeader`).  
2. **Re‑use of existing steps** – The steps for navigating to the login page, entering credentials, and clicking the login button are generic and can be reused across other features that involve authentication.  
3. **Edge‑case handling** – The `Scenario Outline` covers wrong password, wrong 2FA code, missing code, and expired code. The expired‑code scenario assumes the application displays a specific message; adjust the message string if the real app differs.  
4. **Hooks** – The `After` hook clears cookies to keep scenarios isolated.  
5. **Business‑readable language** – All steps are written in plain English, making the scenarios understandable to non‑technical stakeholders