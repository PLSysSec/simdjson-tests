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


if [[ "$wasm" = true ]]; then 
	CFLAGS="-O3 \
		-DLIBCXX_BUILD_EXTERNAL_THREAD_LIBRARY" \
	LDFLAGS="-WL,--export-all -Wl,--growable-table" \
	/opt/wasi-sdk/wasi-sdk-14.0/bin/clang++ \
	--sysroot /opt/wasi-sdk/wasi-sdk-14.0/share/wasi-sysroot \
	-I/home/jgoldman/simdjson-tests \
	-o parse.wasm \
	parse.cpp \
	simdjson.cpp \
	-latomic

	# wamrc --enable-multi-thread -o test.aot test.wasm

elif [[ "$simd" = true ]]; then
  c++ -o parse parse.cpp -O3 simdjson.cpp
  hyperfine './parse haswell' 
else
  c++ -o parse parse.cpp simdjson.cpp
  hyperfine './parse fallback'
fi
