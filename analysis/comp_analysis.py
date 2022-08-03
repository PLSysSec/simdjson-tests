#!/usr/bin/python3
import numpy as np
import sys
import matplotlib.pyplot as plt
import config

def get_improvement(hi, lo, performance):
  """
  Get improvement from two execution speeds.
  Arguments:
    hi, lo: (double) execution speeds
    performance: (bool) True if calculating performance increase, False if calculating time reduction.
  Returns: (double) Calculated improvement
  """
  if (lo > hi):
    print('input order incorrect')
    sys.exit()
  return 100 * (hi - lo) / (lo if performance else hi)


def generate_data():
  """
  Generate the data object
  Returns: (dict) data = {filename: (average execution time, [raw data])}
  """
  data = {}
  config.init()
  for fn in config.stat_struct.keys():
    raw_data = np.genfromtxt(fn,delimiter=',')
    data[fn] = (np.mean(raw_data), raw_data)
  return data


def generate_txt(data):
  """
  Generate output .txt file
  Arguments:
    data = {filename: (average execution time, [raw data])}
  """
  print('hello world')


def generate_plt(data):
  """
  Generate output histogram .png file
  Arguments:
    data = {filename: (average execution time, [raw data])}
  """
  print('hello world')


def main():
  data = generate_data()
  generate_txt(data)
  generate_plt(data)


if __name__ == "__main__":
  main()