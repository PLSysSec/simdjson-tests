#!/bin/bash
set -e

# haswell: Intel/AMD AVX2
# westmere: Intel/AMD SSE4.2
# icelake might also work - still buggy
SIMD_IMPLEMENTATIONS="haswell westmere"
# file to parse in testing
PARSE_FILE=large-file.json
# heap size necessary for running iwasm with large-file.json
LARGE_HEAP=500000000
# number of iterations to test 
N=250
# directory to place output csv files
CSV_DIR=results/raw-data

while getopts "hsw" OPTION
do
	case $OPTION in
		h) help
				exit;;
		s) simd=true;;
		w) wasm=true;;
	esac
done

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

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
  PREFIX="-DWAMR_BUILD_SIMD="
  if [[ -n "$1" ]]; then OPT="${PREFIX}1"; else OPT="${PREFIX}0"; fi
  cmake .. -DWAMR_BUILD_BULK_MEMORY=1 -DWAMR_BUILD_LIB_PTHREAD=1 ${OPT}
  make
}

if [[ "$wasm" = true ]]; then 
  echo "compiling parse.cpp to wasm target..."
  if [[ "$simd" = true ]]; then OPT="-msimd128"; fi
  em++ -O3 -mbulk-memory -matomics $OPT               \
    -I${SIMDE_PATH}/simde/wasm                        \
    -Wl,--export=__data_end,--export=__heap_base      \
    -Wl,--shared-memory,--no-check-features           \
    -s ERROR_ON_UNDEFINED_SYMBOLS=0                   \
    -o out/parse.wasm                                 \
    parse.cpp simdjson.cpp

  # Testing code for SIMD intrinsics 
  echo "generating wat file..."
  ${WABT_PATH}/build/wasm2wat \
    --enable-threads \
    -o out/parse${OUT}.wat \
    out/parse.wasm

  echo "rebuilding iwasm..."
  cd ${WAMR_PATH}/product-mini/platforms/linux/build
  build_with_pthread $simd
  echo "rebuilding wamr..."
  cd ${WAMR_PATH}/wamr-compiler/build 
  build_with_pthread $simd
  cd ${SCRIPT_PATH}   

  echo "building AOT module..."
  ${WAMR_PATH}/wamr-compiler/build/wamrc      \
    --enable-multi-thread                     \
    -o out/parse.aot                          \
    out/parse.wasm

  if [[ "$simd" = true ]]; then 
    set -- $SIMD_IMPLEMENTATIONS
    #imp=$1 # seems to be somewhat faster when using "fallback"
    imp="fallback"
    out="simd128"
  else 
    imp="fallback" 
    out="fallback"
  fi
  # TODO: step not working for WASM - incorporate SIMDe
  echo "running iwasm..."
  cat json-files/${PARSE_FILE} |                          \
    ${WAMR_PATH}/product-mini/platforms/linux/build/iwasm \
    --dir=${SCRIPT_PATH}                                  \
    --heap-size=${LARGE_HEAP}                             \
    out/parse.aot "$imp" "$N"                             \
    > ${CSV_DIR}/wasm_${out}.csv

else
  echo "compiling parse.cpp to native target..."
  g++ -O3 -o out/parse parse.cpp simdjson.cpp  

  if [[ "$simd" = true ]]; then
    for imp in $SIMD_IMPLEMENTATIONS; do
      echo "testing $imp..."
      cat json-files/${PARSE_FILE} | out/parse "$imp" "$N" \
      > ${CSV_DIR}/native_${imp}.csv
    done

  else
    echo "testing fallback..."
    cat json-files/${PARSE_FILE} | out/parse "fallback" "$N" \
    > ${CSV_DIR}/native_fallback.csv
  fi
fi