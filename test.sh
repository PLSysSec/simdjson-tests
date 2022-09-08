#!/bin/bash
set -e

build_with_pthread() {
  PREFIX="-DWAMR_BUILD_SIMD="
  if [[ -n "$1" ]]; then OPT="${PREFIX}1"; else OPT="${PREFIX}0"; fi
  cmake .. -DWAMR_BUILD_BULK_MEMORY=1 -DWAMR_BUILD_LIB_PTHREAD=1 ${OPT}
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

echo "rebuilding iwasm"
cd ${WAMR_PATH}/product-mini/platforms/linux/build
build_with_pthread $simd
echo "rebuilding wamr"
cd ${WAMR_PATH}/wamr-compiler/build 
build_with_pthread $simd
cd ${SCRIPT_PATH}   