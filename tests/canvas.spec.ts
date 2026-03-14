import { test, expect } from "@playwright/test";
import { targets } from "./targets";

for (const target of targets) {
  test.describe(`canvas (${target.name})`, () => {
    test.beforeEach(async ({ page }) => {
      await page.goto(`/canvas/canvas.${target.ext}`);
    });

    test("app loads with heading, canvas, and clear button", async ({ page }) => {
      await expect(page.locator("h1")).toHaveText("Drawing Pad");
      await expect(page.locator("#draw-canvas")).toBeVisible();
      await expect(page.locator(".clear-btn")).toHaveText("Clear");
      await expect(page.locator(".stroke-count")).toHaveText("0 strokes");
    });

    test("drawing a stroke changes canvas content", async ({ page }) => {
      const canvas = page.locator("#draw-canvas");
      const blank = await canvas.evaluate((el: HTMLCanvasElement) =>
        el.toDataURL()
      );

      // Simulate a mouse drag on the canvas
      const box = (await canvas.boundingBox())!;
      const startX = box.x + 100;
      const startY = box.y + 100;
      await page.mouse.move(startX, startY);
      await page.mouse.down();
      await page.mouse.move(startX + 80, startY + 40, { steps: 5 });
      await page.mouse.up();

      // Canvas should now have visible content
      const drawn = await canvas.evaluate((el: HTMLCanvasElement) =>
        el.toDataURL()
      );
      expect(drawn).not.toBe(blank);
      await expect(page.locator(".stroke-count")).toHaveText("1 strokes");
    });

    test("clear button resets the canvas", async ({ page }) => {
      const canvas = page.locator("#draw-canvas");

      // Draw something first
      const box = (await canvas.boundingBox())!;
      const startX = box.x + 50;
      const startY = box.y + 50;
      await page.mouse.move(startX, startY);
      await page.mouse.down();
      await page.mouse.move(startX + 100, startY + 60, { steps: 5 });
      await page.mouse.up();

      await expect(page.locator(".stroke-count")).toHaveText("1 strokes");

      // Capture drawn state
      const drawn = await canvas.evaluate((el: HTMLCanvasElement) =>
        el.toDataURL()
      );

      // Click clear
      await page.locator(".clear-btn").click();

      // Canvas should be blank again
      const cleared = await canvas.evaluate((el: HTMLCanvasElement) =>
        el.toDataURL()
      );
      expect(cleared).not.toBe(drawn);
      await expect(page.locator(".stroke-count")).toHaveText("0 strokes");
    });

    test("multiple strokes are tracked", async ({ page }) => {
      const canvas = page.locator("#draw-canvas");
      const box = (await canvas.boundingBox())!;

      // Draw first stroke
      await page.mouse.move(box.x + 50, box.y + 50);
      await page.mouse.down();
      await page.mouse.move(box.x + 100, box.y + 80, { steps: 3 });
      await page.mouse.up();

      // Draw second stroke
      await page.mouse.move(box.x + 200, box.y + 200);
      await page.mouse.down();
      await page.mouse.move(box.x + 300, box.y + 250, { steps: 3 });
      await page.mouse.up();

      await expect(page.locator(".stroke-count")).toHaveText("2 strokes");
    });
  });
}
