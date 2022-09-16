#!/usr/bin/python3
import numpy as np
import sys
import matplotlib.pyplot as plt
import config


def get_improvement(hi: float, lo: float, is_performance: bool, switch: bool, n: int) -> float:
    """
    Get improvement from two execution speeds.
    Arguments:
      hi, lo: (float) execution speeds
      is_performance: (bool) True if calculating performance increase, False if calculating time reduction.
      switch: (bool) True if in the case lo > hi, the variables should be switched. False if the system should exit
      n: (int) Index of which test were are performing
    Returns: (float) Calculated improvement
    """
    if (lo > hi):
        if (switch):
            print("order switched on test " + str(n))
            return get_improvement(lo, hi, is_performance, False, n)
        print('input order incorrect on test ' + str(n))
        sys.exit()
    return 100 * (hi - lo) / (lo if is_performance else hi)


def generate_data() -> dict:
    """
    Generate the data object
    Returns: (dict) data = {filename: (average execution time, [raw data])}
    """
    data = {}
    config.init()
    for fn in config.stat_struct.keys():
        raw_data = np.genfromtxt(fn, delimiter=',')
        data[fn] = (np.mean(raw_data), raw_data)
    print("data generated...")
    return data


def generate_txt(data: dict) -> None:
    """
    Generate output .txt file
    Arguments:
      data = {filename: (average execution time, [raw data])}
    """
    native_wh_p = get_improvement(
        data[config.native_westmere_fn][0], data[config.native_haswell_fn][0], True, True, 0)
    native_hf_p = get_improvement(
        data[config.native_fallback_fn][0], data[config.native_haswell_fn][0], True, False, 1)
    native_wf_p = get_improvement(
        data[config.native_fallback_fn][0], data[config.native_westmere_fn][0], True, False, 2)
    wasm_sf_p = get_improvement(
        data[config.wasm_fallback_fn][0], data[config.wasm_simd128_fn][0], True, False, 3)
    wasm_s_native_h_p = get_improvement(
        data[config.wasm_simd128_fn][0], data[config.native_haswell_fn][0], True, False, 4)
    wasm_s_native_w_p = get_improvement(
        data[config.wasm_simd128_fn][0], data[config.native_westmere_fn][0], True, False, 5)
    wasm_f_native_f_p = get_improvement(
        data[config.wasm_fallback_fn][0], data[config.native_fallback_fn][0], True, False, 6)

    native_wh_t = get_improvement(
        data[config.native_westmere_fn][0], data[config.native_haswell_fn][0], False, True, 7)
    native_hf_t = get_improvement(
        data[config.native_fallback_fn][0], data[config.native_haswell_fn][0], False, False, 8)
    native_wf_t = get_improvement(
        data[config.native_fallback_fn][0], data[config.native_westmere_fn][0], False, False, 9)
    wasm_sf_t = get_improvement(
        data[config.wasm_fallback_fn][0], data[config.wasm_simd128_fn][0], False, False, 10)
    wasm_s_native_h_t = get_improvement(
        data[config.wasm_simd128_fn][0], data[config.native_haswell_fn][0], False, False, 11)
    wasm_s_native_w_t = get_improvement(
        data[config.wasm_simd128_fn][0], data[config.native_westmere_fn][0], False, False, 12)
    wasm_f_native_f_t = get_improvement(
        data[config.wasm_fallback_fn][0], data[config.native_fallback_fn][0], False, False, 13)

    with open(config.comp_info[0], 'w') as f:
        f.write("averages: \n")
        f.write("  native fallback  : " +
                str(data[config.native_fallback_fn][0]) + "\n")
        f.write("  native haswell   : " +
                str(data[config.native_haswell_fn][0]) + "\n")
        f.write("  native westmere  : " +
                str(data[config.native_westmere_fn][0]) + "\n")
        f.write("  wasm fallback    : " +
                str(data[config.wasm_fallback_fn][0]) + "\n")
        f.write("  wasm simd128     : " +
                str(data[config.wasm_simd128_fn][0]) + "\n")
        f.write("\n")
        for i in range(1, -1, -1):
            f.write(
                "performance increase percentage [100 * (hi - lo) / lo]: \n" if i else "time reduction percentage [100 * (hi - lo) / hi]: \n")
            f.write("  native westmere -> native haswell  : " +
                    (str(native_wh_p) if i else str(native_wh_t)) + "\n")
            f.write("  native fallback -> native haswell  : " +
                    (str(native_hf_p) if i else str(native_hf_t)) + "\n")
            f.write("  native fallback -> native westmere : " +
                    (str(native_wf_p) if i else str(native_wf_t)) + "\n")
            f.write("  wasm fallback -> wasm simd128      : " +
                    (str(wasm_sf_p) if i else str(wasm_sf_t)) + "\n")
            f.write("  wasm simd128 -> native haswell     : " +
                    (str(wasm_s_native_h_p) if i else str(wasm_s_native_h_t)) + "\n")
            f.write("  wasm simd128 -> native westmere    : " +
                    (str(wasm_s_native_w_p) if i else str(wasm_s_native_w_t)) + "\n")
            f.write("  wasm fallback -> native fallback   : " +
                    (str(wasm_f_native_f_p) if i else str(wasm_f_native_f_t)) + "\n")
            f.write("\n")
    print("text generated...")


def generate_hist(data: dict) -> None:
    """
    Generate output histogram .png file
    Arguments:
      data = {filename: (average execution time, [raw data])}
    """
    bins = np.arange(config.MIN, config.MAX, config.delta)
    plt.hist(data[config.native_fallback_fn][1], bins, alpha=config.alpha,
             label=config.comp_info[1][0], edgecolor="black")
    plt.hist(data[config.native_haswell_fn][1], bins, alpha=config.alpha,
             label=config.comp_info[1][1], edgecolor="black")
    plt.hist(data[config.native_westmere_fn][1], bins, alpha=config.alpha,
             label=config.comp_info[1][2], edgecolor="black")
    plt.hist(data[config.wasm_fallback_fn][1], bins, alpha=config.alpha,
             label=config.comp_info[1][3], edgecolor="black")
    plt.hist(data[config.wasm_simd128_fn][1], bins, alpha=config.alpha,
             label=config.comp_info[1][4], edgecolor="black")

    plt.xlabel("Time [s]")
    plt.ylabel("Frequency")
    plt.legend(loc='upper right', fontsize='small')
    plt.title(config.comp_info[2])
    plt.savefig(config.comp_info[3])

    print("histogram generated...")


def generate_bar(data: dict) -> None:
    """
    Generate output bar .png file
    Arguments
      data = {filename: (average execution time, [raw data])}
    """
    x_axis = config.comp_info[1]
    y_axis = np.zeros(5)
    for i in range(5):
        y_axis[i] = list(data.values())[i][0]

    plt.figure(figsize=config.fig_size)
    plt.bar(x_axis, y_axis)
    plt.xlabel('Implementation')
    plt.ylabel('Time [s]')
    plt.title(config.comp_info[2])
    plt.savefig(config.comp_info[4])

    print("bar chart generated...")


def main():
    data = generate_data()
    generate_txt(data)
    generate_hist(data)
    plt.close()
    generate_bar(data)


if __name__ == "__main__":
    main()
