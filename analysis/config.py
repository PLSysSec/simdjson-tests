#!/usr/bin/python3

def init():
    # minimum and maximum x-values for output graph
    global MIN, MAX
    MIN = 0.00
    MAX = 0.10

    # maximum variance - ensures benchmarking environment properly set
    global MAX_VAR
    MAX_VAR=10**-6

    # directory for results output files
    results_dir = 'results/'
    raw_data_dir = 'raw-data/'
    png_dir = 'graphs/'

    # raw data filenames
    global native_fallback_fn, native_haswell_fn, native_westmere_fn
    global wasm_fallback_fn, wasm_simd128_fn
    native_fallback_fn = results_dir + raw_data_dir + 'native_fallback.csv'
    native_haswell_fn = results_dir + raw_data_dir + 'native_haswell.csv'
    native_westmere_fn = results_dir + raw_data_dir + 'native_westmere.csv'
    wasm_fallback_fn = results_dir + raw_data_dir + 'wasm_fallback.csv'
    wasm_simd128_fn = results_dir + raw_data_dir + 'wasm_simd128.csv'

    # {filename : (.txt file for statistical results, histogram title, .png file for histogram)}
    global stat_struct
    stat_struct = {
        native_fallback_fn:
        (
          results_dir + 'native_fallback_results.txt',
          'Native Parsing without SIMD Instructions',
          results_dir + png_dir + 'native_fallback.png'
        ),
        native_haswell_fn:
        (
          results_dir + 'native_haswell_results.txt',
          'Native Parsing with Haswell (AVX2) Instructions',
          results_dir + png_dir + 'native_haswell.png'
        ),
        native_westmere_fn:
        (
          results_dir + 'native_westmere_results.txt',
          'Native Parsing with Westmere (SSE4.2) Instructions',
          results_dir + png_dir + 'native_westmere.png'
        ),
        wasm_fallback_fn:
        (
          results_dir + 'wasm_fallback_results.txt',
          'WASM Parsing without SIMD Instructions',
          results_dir + png_dir + 'wasm_fallback.png'
        ),
        wasm_simd128_fn:
        (
          results_dir + 'wasm_simd128_results.txt',
          'WASM Parsing with SIMD128 Instructions',
          results_dir + png_dir + 'wasm_simd128.png'
        )
    }

    # output information for comp_analysis.py
    global comp_info
    comp_info = (
        results_dir + 'comparitive_results.txt',
        (
          'Native Fallback',
          'Native Haswell (AVX2)',
          'Native Westmere (SSE 4.2)',
          'WASM Fallback',
          'WASM SIMD128'
        ),
        'Comparison of Parsing Speeds',
        results_dir + png_dir + 'comparison.png',
        results_dir + png_dir + 'bar_chart.png'
    )
