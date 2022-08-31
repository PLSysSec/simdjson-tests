#!/bin/bash
set -e

help() {
  echo "Build the simdjson library and corresponding parse.cpp"
  echo "application. Run tests for the specific build target and"
  echo "available SIMD implementations (if specified)."
  echo
  echo "Syntax: bash run.sh -[h|s|w]"
  echo "options:"
  echo "h   Print this help menu."
  echo "s   SIMD instructions included."
  echo "w   Build to WASM target."
  echo
}

build_with_pthread() {
    cmake .. -DWAMR_BUILD_BULK_MEMORY=1 -DWAMR_BUILD_LIB_PTHREAD=1
    make
}

while getopts "hsw" OPTION
do
	case $OPTION in
		h) help
				exit;;
		s) simd=true;;
		w) wasm=true;;
	esac
done


# haswell: Intel/AMD AVX2
# westmere: Intel/AMD SSE4.2
# icelake might also work - still buggy
SIMD_IMPLEMENTATIONS="haswell westmere"
PARSE_FILE=twitter.json
N=2

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")


if [[ "$wasm" = true ]]; then 
  echo "compiling parse.cpp to wasm target..."
  em++ -O3 -mbulk-memory -matomics                    \
    -Wl,--export=__data_end,--export=__heap_base      \
    -Wl,--shared-memory,--no-check-features           \
    -s ERROR_ON_UNDEFINED_SYMBOLS=0                   \
    -o out/parse.wasm                                 \
    parse.cpp simdjson.cpp

  echo "rebuilding iwasm"
  cd ${WAMR_PATH}/product-mini/platforms/linux/build
  build_with_pthread
  echo "rebuilding wamr"
  cd ${WAMR_PATH}/wamr-compiler/build 
  build_with_pthread
  cd ${SCRIPT_PATH}   

  echo "building AOT module"
  ${WAMR_PATH}/wamr-compiler/build/wamrc      \
    --enable-multi-thread                     \
    -o out/parse.aot                          \
    out/parse.wasm

  echo "running iwasm"
  ${WAMR_PATH}/product-mini/platforms/linux/build/iwasm \
    --dir=${SCRIPT_PATH} \
    out/parse.aot "fallback" ${SCRIPT_PATH}/json-files/${PARSE_FILE} "${N}"
  # "fallback" ${SCRIPT_PATH}/json-files/${PARSE_FILE} "${N}"

else
  echo "compiling parse.cpp to native target..."
  g++ -O3 -o out/parse parse.cpp simdjson.cpp  

  if [[ "$simd" = true ]]; then
    for imp in $SIMD_IMPLEMENTATIONS; do
      cp /dev/null results/native_${imp}.csv
      echo "testing $imp..."
      out/parse ${imp} json-files/${PARSE_FILE} "${N}" \
      > results/native_${imp}.csv
    done

  else
    cp /dev/null results/native_fallback.csv
    echo "testing fallback..."
    out/parse fallback json-files/${PARSE_FILE} "${N}" \
    > results/native_fallback.csv
  fi
fi