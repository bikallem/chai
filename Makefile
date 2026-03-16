EXAMPLES := benchmark canvas clock counters fetch regressions router todo

WEBAPI_DIR := .mooncakes/bikallem/webapi
TRIM       := $(WEBAPI_DIR)/_build/native/release/build/trim/trim.exe
WEBAPI_MJS := $(WEBAPI_DIR)/src/webapi.mjs
BUILD_DIR  := src/examples/_build

.PHONY: all build build-js build-wasm trim check fmt test bench clean

all: clean fmt build test info

build: build-js build-wasm trim

build-js:
	moon build --target js --release --target-dir $(BUILD_DIR); \

build-wasm:
	moon build --target wasm-gc --release --target-dir $(BUILD_DIR); \

trim: build-wasm
	@for pkg in $(EXAMPLES); do \
		$(TRIM) $(BUILD_DIR)/wasm-gc/release/build/examples/$$pkg/$$pkg.wasm \
			--source $(WEBAPI_MJS); \
	done

check:
	moon check --target js
	moon check --target wasm-gc

fmt:
	moon fmt

info:
	moon info

test: build
	moon test --target js
	cd tests && npx playwright test

bench: build
	cd tests && BENCH=1 npx playwright test benchmark.spec.ts

clean:
	moon clean
	rm -rf $(BUILD_DIR)
