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
PARSE_FILE=large-file.json
N=5

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")


if [[ "$wasm" = true ]]; then 
  echo "compiling parse.cpp to wasm target..."
	emcc -O3 \
  -I${SIMDE_PATH}/wasm \
  -o out/parse.wasm \
  parse.cpp simdjson.cpp \
  2> /dev/null

  # Extraneous step - only for checking WASM code
  echo "converting .wasm to .wat..."
  ${WABT_PATH}/build/wasm2wat -o out/parse.wat out/parse.wasm
  
  if [[ "$simd" = true ]]; then 
    echo "rebuilding WAMR with SIMD support..."
    cd ${WAMR_PATH}/wamr-compiler/build 
    cmake .. -DWAMR_BUILD_SIMD=1
    make 
    cd ${SCRIPT_PATH}

  else 
    echo "rebuilding WAMR without SIMD support..."
    cd ${WAMR_PATH}/wamr-compiler/build 
    cmake .. -DWAMR_BUILD_SIMD=0
    make 
    cd ${SCRIPT_PATH}
  fi

  echo "compiling to AOT with wamrc..."
  ${WAMR_PATH}/wamr-compiler/build/wamrc \
  --enable-multi-thread \
  -o out/parse.aot \
  out/parse.wasm

else
  echo "compiling parse.cpp to native target..."
  g++ -O3 -o out/parse parse.cpp simdjson.cpp  

  if [[ "$simd" = true ]]; then
    for imp in $SIMD_IMPLEMENTATIONS; do
      cp /dev/null results/native_${imp}.csv
      echo "testing $imp..."
      for i in $(seq $N); do 
        out/parse ${imp} json-files/${PARSE_FILE} results/native_${imp}.csv
      done
    done

  else
    cp /dev/null results/native_fallback.csv
    echo "testing fallback..."
    for i in $(seq $N); do
        out/parse fallback json-files/${PARSE_FILE} results/native_fallback.csv
    done
  fi
fi