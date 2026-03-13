import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/todo/todo.js.html");
});

test("app loads with heading, input, and counter", async ({ page }) => {
  await expect(page.locator("h1")).toHaveText("todos");
  await expect(page.locator(".todo-input")).toHaveAttribute(
    "placeholder",
    "What needs to be done?"
  );
  await expect(page.locator(".todo-count")).toHaveText("0 items left");
});

test("add todo via button", async ({ page }) => {
  await page.locator(".todo-input").fill("Buy milk");
  await page.locator(".add-btn").click();

  await expect(page.locator(".todo-text")).toHaveText("Buy milk");
  await expect(page.locator(".todo-count")).toHaveText("1 item left");
});

test("add todo via Enter key", async ({ page }) => {
  await page.locator(".todo-input").fill("Walk the dog");
  await page.locator(".todo-input").press("Enter");

  await expect(page.locator(".todo-text")).toHaveText("Walk the dog");
  await expect(page.locator(".todo-count")).toHaveText("1 item left");
});

test("successful add clears the input field", async ({ page }) => {
  const input = page.locator(".todo-input");

  await input.fill("Clear me");
  await page.locator(".add-btn").click();

  await expect(page.locator(".todo-text")).toHaveText("Clear me");
  await expect(input).toHaveValue("");
});

test("toggle todo marks it completed", async ({ page }) => {
  await page.locator(".todo-input").fill("Test item");
  await page.locator(".add-btn").click();

  await page.locator('.todo-item input[type="checkbox"]').click();

  await expect(page.locator(".todo-item")).toHaveClass(/completed/);
  await expect(page.locator(".todo-count")).toHaveText("0 items left");
});

test("delete todo removes it", async ({ page }) => {
  await page.locator(".todo-input").fill("Delete me");
  await page.locator(".add-btn").click();
  await expect(page.locator(".todo-item")).toHaveCount(1);

  await page.locator(".delete-btn").click();

  await expect(page.locator(".todo-item")).toHaveCount(0);
  await expect(page.locator(".todo-count")).toHaveText("0 items left");
});

test("filter: Active shows only uncompleted items", async ({ page }) => {
  await page.locator(".todo-input").fill("Active item");
  await page.locator(".add-btn").click();
  await page.locator(".todo-input").fill("Done item");
  await page.locator(".add-btn").click();

  // Complete the second item
  await page.locator('.todo-item:nth-child(2) input[type="checkbox"]').click();

  await page.locator(".filter-btn", { hasText: "Active" }).click();

  await expect(page.locator(".todo-item")).toHaveCount(1);
  await expect(page.locator(".todo-text")).toHaveText("Active item");
});

test("filter: Completed shows only completed items", async ({ page }) => {
  await page.locator(".todo-input").fill("Active item");
  await page.locator(".add-btn").click();
  await page.locator(".todo-input").fill("Done item");
  await page.locator(".add-btn").click();

  await page.locator('.todo-item:nth-child(2) input[type="checkbox"]').click();

  await page.locator(".filter-btn", { hasText: "Completed" }).click();

  await expect(page.locator(".todo-item")).toHaveCount(1);
  await expect(page.locator(".todo-text")).toHaveText("Done item");
});

test("filter: All shows all items", async ({ page }) => {
  await page.locator(".todo-input").fill("Item A");
  await page.locator(".add-btn").click();
  await page.locator(".todo-input").fill("Item B");
  await page.locator(".add-btn").click();

  await page.locator('.todo-item:nth-child(1) input[type="checkbox"]').click();

  await page.locator(".filter-btn", { hasText: "Active" }).click();
  await expect(page.locator(".todo-item")).toHaveCount(1);

  await page.locator(".filter-btn", { hasText: "All" }).click();
  await expect(page.locator(".todo-item")).toHaveCount(2);
});

test("clear completed removes completed items", async ({ page }) => {
  await page.locator(".todo-input").fill("Keep me");
  await page.locator(".add-btn").click();
  await page.locator(".todo-input").fill("Remove me");
  await page.locator(".add-btn").click();

  await page.locator('.todo-item:nth-child(2) input[type="checkbox"]').click();

  await page.locator(".clear-btn").click();

  await expect(page.locator(".todo-item")).toHaveCount(1);
  await expect(page.locator(".todo-text")).toHaveText("Keep me");
});

test("empty input does not add a todo", async ({ page }) => {
  await page.locator(".add-btn").click();

  await expect(page.locator(".todo-item")).toHaveCount(0);
  await expect(page.locator(".todo-count")).toHaveText("0 items left");
});
