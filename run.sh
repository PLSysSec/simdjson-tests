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
  echo "compiling parse-wasm.cpp to wasm target..."
	# emcc -O3 -g \
  # -I${SIMDE_PATH}/wasm \
  # -Wno-format \
  # -o out/parse.wasm \
  # parse-wasm.cpp simdjson.cpp \
  # --preload-file json-files/${PARSE_FILE} 

  emcc -O3 -g \
  -matomics -mbulk-memory -sMALLOC="none" \
  -Wl,--export=__data_end,--export=__heap_base \
  -Wl,--shared-memory,--no-check-features \
  -sERROR_ON_UNDEFINED_SYMBOLS=0 \
  -I${SIMDE_PATH}/wasm \
  -o out/parse.wasm \
  parse-wasm.cpp simdjson.cpp \
  --preload-file json-files/${PARSE_FILE} \
  2> /dev/null
  
  if [[ "$simd" = true ]]; then 
    echo "rebuilding WAMR with SIMD support..."
    cd ${WAMR_PATH}/wamr-compiler/build 
    cmake .. -DWAMR_BUILD_SIMD=1 -DWAMR_BUILD_LIB_PTHREAD=1
    make 
    cd ${SCRIPT_PATH}

  else 
    echo "rebuilding WAMR without SIMD support..."
    cd ${WAMR_PATH}/wamr-compiler/build 
    cmake .. -DWAMR_BUILD_SIMD=1 -DWAMR_BUILD_LIB_PTHREAD=1
    make 
    cd ${SCRIPT_PATH}
  fi

  echo "compiling to AOT with wamrc..."
  ${WAMR_PATH}/wamr-compiler/build/wamrc \
  --enable-multi-thread \
  -o out/parse.aot \
  out/parse.wasm

  if [[ "$simd" = true ]]; then
    for imp in $SIMD_IMPLEMENTATIONS; do
      echo "testing $imp..."
      ${WAMR_PATH}/product-mini/platforms/linux/build/iwasm \
      --dir=${SCRIPT_PATH} \
      --dir=${SCRIPT_PATH}/json-files \
      --dir=${SCRIPT_PATH}/results \
      -v=5 \
      out/parse.aot \
      "${imp}" \
      ${SCRIPT_PATH}/json-files/${PARSE_FILE} \
      "${N}" \
      > results/wasm_${imp}.csv
    done

  else
    echo "testing fallback..."
    ${WAMR_PATH}/product-mini/platforms/linux/build/iwasm \
    --dir=${SCRIPT_PATH} \
    --dir=${SCRIPT_PATH}/json-files \
    --dir=${SCRIPT_PATH}/results \
    out/parse.aot \
    "fallback" \
    ${SCRIPT_PATH}/json-files/${PARSE_FILE} \
    "${N}" \
    > results/wasm_fallback.csv
  fi

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