import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/counters/counters.js.html");
});

test("app loads with heading and two counters at zero", async ({ page }) => {
  await expect(page.locator("h1")).toHaveText("Counters");
  await expect(page.locator(".counter-wrapper")).toHaveCount(2);
  await expect(page.locator(".counter-wrapper").nth(0).locator("h2")).toHaveText("Counter A");
  await expect(page.locator(".counter-wrapper").nth(1).locator("h2")).toHaveText("Counter B");
  await expect(page.locator(".counter-value").nth(0)).toHaveText("0");
  await expect(page.locator(".counter-value").nth(1)).toHaveText("0");
});

test("increment counter A", async ({ page }) => {
  const counterA = page.locator(".counter-wrapper").nth(0);
  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await counterA.locator(".counter-btn", { hasText: "+" }).click();

  await expect(counterA.locator(".counter-value")).toHaveText("2");
  await expect(page.locator(".counter-value").nth(1)).toHaveText("0");
});

test("decrement counter B", async ({ page }) => {
  const counterB = page.locator(".counter-wrapper").nth(1);
  await counterB.locator(".counter-btn", { hasText: "-" }).click();

  await expect(counterB.locator(".counter-value")).toHaveText("-1");
  await expect(page.locator(".counter-value").nth(0)).toHaveText("0");
});

test("counters are independent", async ({ page }) => {
  const counterA = page.locator(".counter-wrapper").nth(0);
  const counterB = page.locator(".counter-wrapper").nth(1);

  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await counterB.locator(".counter-btn", { hasText: "-" }).click();

  await expect(counterA.locator(".counter-value")).toHaveText("3");
  await expect(counterB.locator(".counter-value")).toHaveText("-1");
});

test("reset all resets both counters to zero", async ({ page }) => {
  const counterA = page.locator(".counter-wrapper").nth(0);
  const counterB = page.locator(".counter-wrapper").nth(1);

  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await counterB.locator(".counter-btn", { hasText: "+" }).click();

  await expect(counterA.locator(".counter-value")).toHaveText("2");
  await expect(counterB.locator(".counter-value")).toHaveText("1");

  await page.locator(".reset-btn").click();

  await expect(counterA.locator(".counter-value")).toHaveText("0");
  await expect(counterB.locator(".counter-value")).toHaveText("0");
});

test("counters work after reset", async ({ page }) => {
  const counterA = page.locator(".counter-wrapper").nth(0);

  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await expect(counterA.locator(".counter-value")).toHaveText("1");

  await page.locator(".reset-btn").click();
  await expect(counterA.locator(".counter-value")).toHaveText("0");

  await counterA.locator(".counter-btn", { hasText: "+" }).click();
  await expect(counterA.locator(".counter-value")).toHaveText("1");
});
