import { test, expect, type Page } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";

// Skip unless BENCH=1
const skip = !process.env.BENCH;

const implementations = [
  { name: "chai-js", url: "/benchmark/benchmark.js.html" },
  { name: "chai-wasm", url: "/benchmark/benchmark.wasm.html" },
  { name: "vanilla", url: "/benchmark/comparison/vanilla.html" },
  { name: "react", url: "/benchmark/comparison/react.html" },
  { name: "preact", url: "/benchmark/comparison/preact.html" },
];

interface OpDef {
  id: string;
  label: string;
  setup: string | null;
  selector?: string; // CSS selector to click instead of button#id
  waitFor:
    | { type: "count"; count: number }
    | { type: "text"; text: string }
    | { type: "class" }
    | { type: "none" };
}

const operations: OpDef[] = [
  { id: "run", label: "Create 1k", setup: null, waitFor: { type: "count", count: 1000 } },
  { id: "runlots", label: "Create 10k", setup: null, waitFor: { type: "count", count: 10000 } },
  { id: "add", label: "Append 1k", setup: "run", waitFor: { type: "count", count: 2000 } },
  { id: "update", label: "Partial update", setup: "run", waitFor: { type: "text", text: "!!!" } },
  { id: "clear", label: "Clear", setup: "run", waitFor: { type: "count", count: 0 } },
  { id: "swaprows", label: "Swap rows", setup: "run", waitFor: { type: "none" } },
  { id: "run", label: "Replace 1k (2nd)", setup: "run", waitFor: { type: "count", count: 1000 } },
  {
    id: "select",
    label: "Select row",
    setup: "run",
    selector: "#tbody tr:nth-child(2) .lbl",
    waitFor: { type: "class" },
  },
  {
    id: "remove",
    label: "Remove row",
    setup: "run",
    selector: "#tbody tr:first-child a.remove",
    waitFor: { type: "count", count: 999 },
  },
];

const ITERATIONS = 5;
const resultsPath = path.join(__dirname, "benchmark-results.json");

async function clickButton(page: Page, id: string) {
  await page.locator(`#${id}`).click();
}

async function waitForRows(page: Page, count: number) {
  await expect(page.locator("#tbody tr")).toHaveCount(count, { timeout: 30000 });
}

async function runSetup(page: Page, setupOp: string | null) {
  if (setupOp) {
    await clickButton(page, setupOp);
    await waitForRows(page, 1000);
    await page.waitForTimeout(100);
  }
}

/**
 * Measure an operation entirely inside the browser to avoid Playwright
 * round-trip overhead. Clicks the target element, observes the tbody for
 * mutations, and resolves with the elapsed ms after rAF + setTimeout
 * (the standard js-framework-benchmark after-paint measurement).
 */
async function measureOpInBrowser(
  page: Page,
  op: OpDef
): Promise<number> {
  const clickSelector = op.selector ?? `#${op.id}`;

  return page.evaluate(
    ({ clickSelector, waitFor }) => {
      return new Promise<number>((resolve) => {
        const tbody = document.getElementById("tbody")!;
        const t0 = performance.now();

        // Detect completion: observe tbody for any change
        const observer = new MutationObserver(() => {
          // Check if the expected DOM state is reached
          let ready = false;
          switch (waitFor.type) {
            case "count":
              ready = tbody.children.length === waitFor.count;
              break;
            case "text":
              ready =
                tbody.children.length > 0 &&
                (tbody.children[0].querySelector(".lbl")?.textContent ?? "").includes(waitFor.text);
              break;
            case "class":
              ready = tbody.querySelector("tr.danger") !== null;
              break;
            case "none":
              ready = true;
              break;
          }
          if (!ready) return;
          observer.disconnect();
          // Measure after paint (rAF + setTimeout)
          requestAnimationFrame(() => {
            setTimeout(() => {
              resolve(performance.now() - t0);
            }, 0);
          });
        });
        observer.observe(tbody, {
          childList: true,
          subtree: true,
          attributes: true,
          characterData: true,
        });

        // For operations that produce no mutation (swap on <1000 rows),
        // fall back to a timer
        const fallback = setTimeout(() => {
          observer.disconnect();
          requestAnimationFrame(() => {
            setTimeout(() => resolve(performance.now() - t0), 0);
          });
        }, 5000);

        // Click the element to start the operation
        const el = document.querySelector(clickSelector) as HTMLElement;
        el.click();

        // Clear fallback once resolved
        void Promise.resolve().then(() => {
          // noop - fallback handled by timeout
        });
      });
    },
    { clickSelector, waitFor: op.waitFor as any }
  );
}

function saveImplResults(
  implName: string,
  data: Record<string, number[]>
): void {
  let all: Record<string, Record<string, { median: number; times: number[] }>> = {};
  try {
    all = JSON.parse(fs.readFileSync(resultsPath, "utf-8"));
  } catch {
    // file doesn't exist yet
  }
  all[implName] = {};
  for (const [label, times] of Object.entries(data)) {
    const sorted = [...times].sort((a, b) => a - b);
    all[implName][label] = {
      median: sorted[Math.floor(sorted.length / 2)],
      times,
    };
  }
  fs.writeFileSync(resultsPath, JSON.stringify(all, null, 2));
}

test.describe("benchmark", () => {
  test.skip(() => skip, "Set BENCH=1 to run benchmarks");
  test.describe.configure({ mode: "serial" });
  test.setTimeout(300000);

  for (const impl of implementations) {
    test(`${impl.name}`, async ({ page }) => {
      const implResults: Record<string, number[]> = {};

      await page.goto(impl.url, { waitUntil: "networkidle" });
      await page.waitForSelector("#tbody", { state: "attached", timeout: 15000 });

      // Warmup
      await clickButton(page, "run");
      await waitForRows(page, 1000);
      await clickButton(page, "clear");
      await waitForRows(page, 0);
      await page.waitForTimeout(200);

      for (const op of operations) {
        const times: number[] = [];

        for (let i = 0; i < ITERATIONS; i++) {
          // Fresh state
          await clickButton(page, "clear");
          await waitForRows(page, 0);
          await page.waitForTimeout(50);

          // Setup
          await runSetup(page, op.setup);

          // Measure entirely in-browser
          const ms = await measureOpInBrowser(page, op);
          times.push(ms);
        }

        times.sort((a, b) => a - b);
        const median = times[Math.floor(times.length / 2)];
        implResults[op.label] = times;

        console.log(
          `  ${impl.name} | ${op.label}: ${median.toFixed(1)}ms (${times.map((t) => t.toFixed(1)).join(", ")})`
        );
      }

      saveImplResults(impl.name, implResults);
    });
  }

  test("print results", async () => {
    let all: Record<string, Record<string, { median: number; times: number[] }>> = {};
    try {
      all = JSON.parse(fs.readFileSync(resultsPath, "utf-8"));
    } catch {
      console.log("No results found");
      return;
    }

    const opLabels = operations.map((o) => o.label);
    const implNames = implementations.map((i) => i.name);

    const colWidth = 14;
    let header = "Operation".padEnd(20);
    for (const name of implNames) header += name.padStart(colWidth);
    console.log("\n" + "=".repeat(header.length));
    console.log(header);
    console.log("-".repeat(header.length));

    for (const label of opLabels) {
      let line = label.padEnd(20);
      for (const name of implNames) {
        const entry = all[name]?.[label];
        if (entry) {
          line += (entry.median.toFixed(1) + "ms").padStart(colWidth);
        } else {
          line += "-".padStart(colWidth);
        }
      }
      console.log(line);
    }
    console.log("=".repeat(header.length) + "\n");

    console.log(`Full results: ${resultsPath}`);
  });
});
