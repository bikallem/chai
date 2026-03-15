import { test, expect } from "@playwright/test";
import { targets } from "./targets";

for (const target of targets) {
  test.describe(`regressions (${target.name})`, () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(`/regressions/regressions.${target.ext}`);
    });

    test("mounting into a non-empty root clears placeholder content and keeps a single app tree", async ({
      page,
    }) => {
      await expect(page.locator(".mount-placeholder")).toHaveCount(0);
      await expect(page.locator(".regressions-app")).toHaveCount(1);
      await expect(page.locator(".items .item")).toHaveText(["A", "B"]);

      await page.locator(".to-keyed").click();
      await expect(page.locator(".regressions-app")).toHaveCount(1);
      await expect(page.locator(".items .item")).toHaveText(["C"]);
    });

    test("switching plain/keyed child mode fully replaces old children", async ({ page }) => {
      await expect(page.locator(".items .item")).toHaveText(["A", "B"]);

      await page.locator(".to-keyed").click();
      await expect(page.locator(".items .item")).toHaveCount(1);
      await expect(page.locator(".items .item")).toHaveText(["C"]);

      await page.locator(".to-plain").click();
      await expect(page.locator(".items .item")).toHaveText(["A", "B"]);
    });

    test("duplicate keyed children produce undefined behavior without crashing", async ({
      page,
    }) => {
      await page.locator(".to-keyed").click();
      await page.locator(".set-dup").click();
      // Duplicate keys are undefined behavior (like React/Elm) but should not crash
      await expect(page.locator(".regressions-app")).toHaveCount(1);
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
  });
}
