#!/bin/bash
set -e

echo "compiling to wasm"
em++ -o out/test.wasm test.cpp

echo "compiling aot"
${WAMR_PATH}/wamr-compiler/build/wamrc -o out/test.aot out/test.wasm

echo "running with iwasm"
cat json-files/twitter.json | ${WAMR_PATH}/product-mini/platforms/linux/build/iwasm out/test.aot
