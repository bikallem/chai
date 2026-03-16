import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: ".",
  testMatch: "*.spec.ts",
  use: {
    baseURL: "http://localhost:3123",
  },
  webServer: {
    command: "npx serve ../src/examples -l 3123 --no-clipboard",
    port: 3123,
    reuseExistingServer: !process.env.CI,
  },
});
