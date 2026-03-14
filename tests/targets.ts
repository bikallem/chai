/** Test targets for running each example against both JS and wasm-gc builds. */
export const targets = [
  { name: "js", ext: "js.html" },
  // wasm-gc disabled: ref extern / externref nullability mismatch in
  // compiled wasm control flow. Tracked in webapi#18.
  // { name: "wasm-gc", ext: "wasm.html" },
];
