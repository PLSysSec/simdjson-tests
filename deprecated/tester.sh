#!/bin/bash
set -e

echo "hello world"

emcc -O3 \
-matomics -mbulk-memory -s MALLOC="none" \
-Wl,--export=__data_end,--export=__heap_base \
-Wl,--shared-memory,--no-check-features \
-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
-I${SIMDE_PATH}/wasm \
-o out/parse.wasm \
parse-wasm.cpp simdjson.cpp \
--preload-file json-files/${PARSE_FILE} \
2> /dev/null

# /opt/wasi-sdk/wasi-sdk-14.0/bin/clang++ \
# --target=wasm32 \
# --sysroot=/opt/wasm-micro-runtime/wamr-sdk/app/libc-builtin-sysroot \
# -O3 -pthread -nostdlib -z stack-size=32768 \
# -Wl,--shared-memory \
# -Wl,--initial-memory=131072,--max-memory=131072 \
# -Wl,--allow-undefined-file=/opt/wasm-micro-runtime/wamr-sdk/app/libc-builtin-sysroot/share/defined-symbols.txt \
# -Wl,--no-entry \
# -Wl,--export=main \
# -Wl,--export=__heap_base,--export=__data_end \
# -Wl,--export=__wasm_call_ctors \
# test.cpp -o test.wasm

# CFLAGS="-O3 \
# 	-DLIBCXX_BUILD_EXTERNAL_THREAD_LIBRARY" \
# LDFLAGS="-WL,--export-all -Wl,--growable-table" \
# /opt/wasi-sdk/wasi-sdk-14.0/bin/clang++ \
# --sysroot /opt/wasi-sdk/wasi-sdk-14.0/share/wasi-sysroot \
# -I/home/jgoldman/simdjson-tests \
# -o parse.wasm \
# parse.cpp \
# simdjson.cpp \
# -latomic


# echo "compiling to wasm"
# CFLAGS="-O3" \
# LDFLAGS="-WL,--export-all -Wl,--growable-table" \
# /opt/wasi-sdk/wasi-sdk-14.0/bin/clang++ \
# --sysroot /opt/wasi-sdk/wasi-sdk-14.0/share/wasi-sysroot \
# -o test.wasm \
# test.cpp

# echo "compiling to aot"
# /opt/wasm-micro-runtime/wamr-compiler/build/wamrc \
# -o test.aot \
# test.wasm

# echo "running aot"
# /opt/wasm-micro-runtime/product-mini/platforms/linux/build/iwasm \
# --dir=/home/jgoldman/simdjson-tests test.aot \