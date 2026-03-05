import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/regressions/regressions.js.html");
});

test("switching plain/keyed child mode fully replaces old children", async ({ page }) => {
  await expect(page.locator(".items .item")).toHaveText(["A", "B"]);

  await page.locator(".to-keyed").click();
  await expect(page.locator(".items .item")).toHaveCount(1);
  await expect(page.locator(".items .item")).toHaveText("C");

  await page.locator(".to-plain").click();
  await expect(page.locator(".items .item")).toHaveText(["A", "B"]);
});

test("duplicate keyed children fail fast instead of silently corrupting DOM", async ({
  page,
}) => {
  await page.locator(".to-keyed").click();
  const pageError = page.waitForEvent("pageerror", { timeout: 3000 });
  await page.locator(".set-dup").click();
  await expect(pageError).resolves.toBeTruthy();
});

test("link intercepts only plain primary same-tab clicks", async ({ page }) => {
  await expect(page.locator(".link-count")).toHaveText("0");

  const plainClick = await page.evaluate(() => {
    const link = document.querySelector(".spa-link") as HTMLAnchorElement;
    const evt = new MouseEvent("click", { bubbles: true, cancelable: true, button: 0 });
    link.dispatchEvent(evt);
    return evt.defaultPrevented;
  });
  expect(plainClick).toBe(true);
  await expect(page.locator(".link-count")).toHaveText("1");

  const ctrlClick = await page.evaluate(() => {
    const link = document.querySelector(".spa-link") as HTMLAnchorElement;
    const evt = new MouseEvent("click", {
      bubbles: true,
      cancelable: true,
      button: 0,
      ctrlKey: true,
    });
    link.dispatchEvent(evt);
    return evt.defaultPrevented;
  });
  expect(ctrlClick).toBe(false);
  await expect(page.locator(".link-count")).toHaveText("1");

  const blankTargetClick = await page.evaluate(() => {
    const link = document.querySelector(".spa-link-blank") as HTMLAnchorElement;
    const evt = new MouseEvent("click", { bubbles: true, cancelable: true, button: 0 });
    link.dispatchEvent(evt);
    return evt.defaultPrevented;
  });
  expect(blankTargetClick).toBe(false);
  await expect(page.locator(".link-count")).toHaveText("1");
});
