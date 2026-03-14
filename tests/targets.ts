/** Test targets for running each example against both JS and wasm-gc builds. */
export const targets = [
  { name: "js", ext: "js.html" },
  // wasm-gc disabled: externref nullability mismatch — compiler emits
  // (ref extern) where webapi.mjs expects externref. See webapi#18.
  // { name: "wasm-gc", ext: "wasm.html" },
];
