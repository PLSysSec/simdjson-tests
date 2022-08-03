#!/bin/bash
set -e

help() {
  echo "Run statistical analysis of execution tests"
  echo
  echo "Syntax: bash run.sh -[h|s|w]"
  echo "options:"
  echo "h   Print this help menu."
  echo "s   Run analysis for SIMD instructions"
  echo "w   Run analysis for WASM target"
  echo "a   Run all tests"
  echo "c   Run comparatile analysis"
  echo
}


while getopts "hsw" OPTION
do
	case $OPTION in
		h) help
				exit;;
		s) simd=true;;
		w) wasm=true;;
        a) all=true;;
        c) comp=true;;
	esac
done


# haswell: Intel/AMD AVX2
# westmere: Intel/AMD SSE4.2
# icelake might also work - still buggy

SIMD_IMPLEMENTATIONS="haswell westmere"

native_nS() {
    python3 analysis/stat_analysis.py results/native_fallback.csv
}

native_S() {
    for imp in $SIMD_IMPLEMENTATIONS; do
        python3 analysis/stat_analysis.py results/native_${imp}.csv
    done 
}

wasm_nS() {
    python3 analysis/stat_analysis.py results/wasm_fallback.csv
}

wasm_S() {
    python3 analysis/stat_analysis.py results/wasm_fallback.csv
}

if [[ "$all" = true ]]; then
    native_nS
    native_S
    wasm_nS
    wasm_S
elif [[ "$simd" = true && "$wasm" = true ]]; then
    wasm_S
elif [[ "$wasm" = true ]]; then
    wasm_nS
elif [[ "$simd" = true ]]; then
    native_S
else 
    native_nS
fi

if [[ "$comp" = true ]]; then 
    python3 analysis/comp_analysis.py
fi

