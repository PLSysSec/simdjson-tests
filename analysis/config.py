#!/usr/bin/python3

def init():
    # minimum and maximum x-values for output graph
    global MIN, MAX
    MIN = 0.00
    MAX = 0.05

    # directory for results output files
    results_dir = 'results/'

    # output file prefixes
    native_fallback_p = results_dir + 'native_fallback'
    native_haswell_p = results_dir + 'native_haswell'
    native_westmere_p = results_dir + 'native_westmere'
    wasm_fallback_p = results_dir + 'wasm_fallback'
    wasm_simd128_p = results_dir + 'wasm_simd128'

    # raw data filenames
    global native_fallback_fn, native_haswell_fn, native_westmere_fn
    global wasm_fallback_fn, wasm_simd128_fn
    native_fallback_fn = native_fallback_p + '.csv'
    native_haswell_fn = native_haswell_p + '.csv'
    native_westmere_fn = native_westmere_p + '.csv'
    wasm_fallback_fn = wasm_fallback_p + '.csv'
    wasm_simd128_fn = wasm_simd128_p + '.csv'

    # {filename : (.txt file for statistical results, histogram title, .png file for histogram)}
    global stat_struct
    stat_struct = {
        native_fallback_fn:
        (
          native_fallback_p + '_results.txt',
          'Native Parsing without SIMD Instructions',
          native_fallback_p + '.png'
        ),
        native_haswell_fn:
        (
          native_haswell_p + '_results.txt',
          'Native Parsing with Haswell (AVX2) Instructions',
          native_haswell_p + '.png'
        ),
        native_westmere_fn:
        (
          native_westmere_p + '_results.txt',
          'Native Parsing with Westmere (SSE4.2)',
          native_westmere_p + '.png'
        ),
        wasm_fallback_fn:
        (
          wasm_fallback_p + '_results.txt',
          'WASM Parsing without SIMD Instructions',
          wasm_fallback_p + '.png'
        ),
        wasm_simd128_fn:
        (
          wasm_simd128_p + '_results.txt',
          'WASM Parsing with SIMD128 Instructions',
          wasm_fallback_p + '.png'
        )
    }

    # output information for comp_analysis.py
    global comp_struct
    comp_struct = (
        'comparitive_results.txt',
        (
          'Native Fallback',
          'Native Haswell (AVX2)',
          'Native Westmere (SSE 4.2)',
          'WASM Fallback',
          'WASM SIMD128'
        ),
        'Comparison of Parsing Speeds',
        'comparison.png'
    )
