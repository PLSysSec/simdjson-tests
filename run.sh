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

SIMD_IMPLEMENTATIONS="haswell westmere"
PARSE_FILE=large-file.json
N=5

if [[ "$wasm" = true ]]; then 

	emcc -o parse.wasm parse.cpp simdjson.cpp

	# wamrc --enable-multi-thread -o test.aot test.wasm

elif [[ "$simd" = true ]]; then
  echo "compiling parse.cpp to native target..."
  g++ -O3 -o parse parse.cpp simdjson.cpp

  for imp in $SIMD_IMPLEMENTATIONS; do
    cp /dev/null results/native_${imp}.csv
    echo "testing $imp..."
    for i in $(seq $N); do 
      ./parse ${imp} json-files/${PARSE_FILE} results/native_${imp}.csv
    done
  done

else
  echo "compiling parse.cpp to native target..."
  g++ -O3 -o parse parse.cpp simdjson.cpp  

  cp /dev/null results/native_fallback.csv
  echo "testing fallback..."
  for i in $(seq $N)
    do
      ./parse fallback json-files/${PARSE_FILE} results/native_fallback.csv
    done
fi
