import { test, expect } from "@playwright/test";
import { targets } from "./targets";

for (const target of targets) {
  test.describe(`fetch (${target.name})`, () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(`/fetch/fetch.${target.ext}`);
    });

    test("app loads with heading and fetch button", async ({ page }) => {
      await expect(page.locator("h1")).toHaveText("Post Viewer");
      await expect(page.locator(".fetch-btn")).toHaveText("Fetch");
      await expect(page.locator(".post-id")).toHaveText("Post #1");
      await expect(page.locator(".hint")).toHaveText("Click Fetch to load a post");
    });

    test("clicking Fetch shows loading then result", async ({ page }) => {
      await page.route("**/posts/1", (route) =>
        route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ id: 1, title: "Hello", body: "World" }),
        }),
      );

      await page.locator(".fetch-btn").click();
      await expect(page.locator(".body")).toBeVisible();
      await expect(page.locator(".body")).toContainText("Hello");
    });

    test("fetching next post increments ID", async ({ page }) => {
      await page.route("**/posts/1", (route) =>
        route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ id: 1, title: "First" }),
        }),
      );
      await page.route("**/posts/2", (route) =>
        route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ id: 2, title: "Second" }),
        }),
      );

      await page.locator(".fetch-btn").click();
      await expect(page.locator(".body")).toContainText("First");
      await expect(page.locator(".post-id")).toHaveText("Post #2");

      await page.locator(".fetch-btn").click();
      await expect(page.locator(".body")).toContainText("Second");
      await expect(page.locator(".post-id")).toHaveText("Post #3");
    });

    test("network error displays error message", async ({ page }) => {
      await page.route("**/posts/1", (route) => route.abort("connectionrefused"));

      await page.locator(".fetch-btn").click();
      await expect(page.locator(".error")).toBeVisible();
    });

    test("nullish fetch rejection still dispatches error", async ({ page }) => {
      await page.evaluate(() => {
        window.fetch = () => Promise.reject();
      });

      await page.locator(".fetch-btn").click();
      await expect(page.locator(".error")).toHaveText("undefined");
    });
  });
}
