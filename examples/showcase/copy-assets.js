import { cpSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const pkg = "bikallem/chai_examples";
const build = (...p) =>
  resolve(__dirname, "..", "_build", ...p);
const pub = (...p) =>
  resolve(__dirname, "public", "examples", ...p);

const examples = ["todo", "counters", "clock", "router", "fetch", "canvas"];

for (const name of examples) {
  const js = build("js", "release", "build", pkg, name, `${name}.js`);
  if (existsSync(js)) cpSync(js, pub(`${name}.js`));

  const wasm = build("wasm-gc", "release", "build", pkg, name, `${name}.wasm`);
  if (existsSync(wasm)) cpSync(wasm, pub("wasm", `${name}.wasm`));

  const mjs = build("wasm-gc", "release", "build", pkg, name, "webapi.mjs");
  if (existsSync(mjs)) cpSync(mjs, pub("wasm", `${name}.webapi.mjs`));
}

// shared CSS
const css = resolve(__dirname, "..", "examples.css");
if (existsSync(css)) cpSync(css, pub("examples.css"));

// showcase app JS
const showcase = build("js", "release", "build", pkg, "showcase", "showcase.js");
if (existsSync(showcase)) cpSync(showcase, resolve(__dirname, "showcase.js"));

console.log("Showcase assets copied.");
