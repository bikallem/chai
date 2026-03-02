import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/clock/clock.js.html");
});

test("app loads with heading and display at 00:00", async ({ page }) => {
  await expect(page.locator("h1")).toHaveText("Stopwatch");
  await expect(page.locator(".display")).toHaveText("00:00");
});

test("auto-starts after delay via Cmd::after", async ({ page }) => {
  await expect(page.locator(".control-btn").first()).toHaveText("Start");
  await expect(page.locator(".control-btn").first()).toHaveText("Stop", {
    timeout: 2000,
  });
});

test("toggle button starts and stops", async ({ page }) => {
  // Wait for auto-start
  await expect(page.locator(".control-btn").first()).toHaveText("Stop", {
    timeout: 2000,
  });
  // Stop
  await page.locator(".control-btn", { hasText: "Stop" }).click();
  await expect(page.locator(".control-btn").first()).toHaveText("Start");
  // Start again
  await page.locator(".control-btn", { hasText: "Start" }).click();
  await expect(page.locator(".control-btn").first()).toHaveText("Stop");
});

test("reset button resets to 00:00", async ({ page }) => {
  // Wait for auto-start and at least one tick
  await expect(page.locator(".display")).not.toHaveText("00:00", {
    timeout: 3000,
  });
  // Reset
  await page.locator(".control-btn", { hasText: "Reset" }).click();
  await expect(page.locator(".display")).toHaveText("00:00");
  await expect(page.locator(".control-btn").first()).toHaveText("Start");
});

test("space key toggles start/stop", async ({ page }) => {
  // Wait for auto-start
  await expect(page.locator(".control-btn").first()).toHaveText("Stop", {
    timeout: 2000,
  });
  // Space to stop
  await page.keyboard.press("Space");
  await expect(page.locator(".control-btn").first()).toHaveText("Start");
  // Space to start
  await page.keyboard.press("Space");
  await expect(page.locator(".control-btn").first()).toHaveText("Stop");
});

test("R key resets", async ({ page }) => {
  // Wait for auto-start and at least one tick
  await expect(page.locator(".display")).not.toHaveText("00:00", {
    timeout: 3000,
  });
  // R to reset
  await page.keyboard.press("r");
  await expect(page.locator(".display")).toHaveText("00:00");
  await expect(page.locator(".control-btn").first()).toHaveText("Start");
});
