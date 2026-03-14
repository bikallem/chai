/** Test targets for running each example against both JS and wasm-gc builds. */
export const targets = [
  { name: "js", ext: "js.html" },
  // wasm-gc tests are disabled until upstream webapi publishes a release
  // compatible with the current MoonBit compiler (externref vs typed GC refs).
  // { name: "wasm-gc", ext: "wasm.html" },
];
