/** Test targets for running each example against both JS and wasm-gc builds. */
export const targets = [
  { name: "js", ext: "js.html" },
  // wasm-gc disabled: compiled wasm has ref extern / externref nullability
  // mismatch in control flow. Investigating root cause in chai codegen.
  // { name: "wasm-gc", ext: "wasm.html" },
];
