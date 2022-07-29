#!/bin/bash
set -e

while getopts "hsw" OPTION
do
	case $OPTION in
		h) help
				exit;;
		s) simd=true;;
		w) wasm=true;;
	esac
done

PARSE_FILE=large-file.json
N=5

if [[ "$wasm" = true ]]; then 
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

	emcc -o parse.wasm parse.cpp simdjson.cpp

	# try using emscripten

	# wamrc --enable-multi-thread -o test.aot test.wasm

elif [[ "$simd" = true ]]; then
  cp /dev/null results/native_haswell.csv && cp /dev/null results/native_westmere.csv
  g++ -O3 -o parse parse.cpp simdjson.cpp
  for i in $(seq $N)
    do
      ./parse haswell json-files/${PARSE_FILE} results/native_haswell.csv
    done

  for i in $(seq $N)
    do
      ./parse westmere json-files/${PARSE_FILE} results/native_westmere.csv
    done
else
  cp /dev/null results/native_fallback.csv
  g++ -O3 -o parse parse.cpp simdjson.cpp
  for i in $(seq $N)
    do
      ./parse fallback json-files/${PARSE_FILE} results/native_fallback.csv
    done
fi
