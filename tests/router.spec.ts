import { test, expect } from "@playwright/test";
import { targets } from "./targets";

for (const target of targets) {
  test.describe(`router (${target.name})`, () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(`/router/router.${target.ext}`);
    });

    test("app loads with heading and nav links", async ({ page }) => {
      await expect(page.locator("h1")).toHaveText("Router Demo");
      await expect(page.locator(".nav-link")).toHaveCount(3);
      await expect(page.locator(".nav-link").nth(0)).toHaveText("Home");
      await expect(page.locator(".nav-link").nth(1)).toHaveText("About");
      await expect(page.locator(".nav-link").nth(2)).toHaveText("???");
    });

    test("starts on home page", async ({ page }) => {
      await expect(page.locator(".page h2")).toHaveText("Home");
      await expect(page.locator(".page p")).toContainText("Welcome");
    });

    test("navigate to about page", async ({ page }) => {
      await page.locator(".nav-link", { hasText: "About" }).click();
      await expect(page.locator(".page h2")).toHaveText("About");
      await expect(page.locator(".page p")).toContainText("TEA framework");
    });

    test("navigate to unknown route shows 404", async ({ page }) => {
      await page.locator(".nav-link", { hasText: "???" }).click();
      await expect(page.locator(".page h2")).toHaveText("404");
      await expect(page.locator(".page p")).toContainText("not found");
    });

    test("navigate back to home", async ({ page }) => {
      await page.locator(".nav-link", { hasText: "About" }).click();
      await expect(page.locator(".page h2")).toHaveText("About");

      await page.locator(".nav-link", { hasText: "Home" }).click();
      await expect(page.locator(".page h2")).toHaveText("Home");
    });

    test("browser back button works", async ({ page }) => {
      await page.locator(".nav-link", { hasText: "About" }).click();
      await expect(page.locator(".page h2")).toHaveText("About");

      await page.goBack();
      await expect(page.locator(".page h2")).toHaveText("Home");
    });

    test("browser forward button works", async ({ page }) => {
      await page.locator(".nav-link", { hasText: "About" }).click();
      await expect(page.locator(".page h2")).toHaveText("About");

      await page.goBack();
      await expect(page.locator(".page h2")).toHaveText("Home");

      await page.goForward();
      await expect(page.locator(".page h2")).toHaveText("About");
    });

    test("direct hash navigation loads correct page", async ({ page }) => {
      await page.goto(`/router/router.${target.ext}#/about`);
      await expect(page.locator(".page h2")).toHaveText("About");
    });
  });
}
