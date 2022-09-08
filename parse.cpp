#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string>
#include <iostream>
#include "simdjson.h"

#define BILLION 1000000000.0

using namespace simdjson;

int N;

double parse(std::string_view json_sv) {
  struct timespec start, end;
  double dt;
  clock_gettime(CLOCK_REALTIME, &start);
  
  ondemand::parser parser; 
  padded_string json = padded_string(json_sv);
  ondemand::document doc = parser.iterate(json);

  clock_gettime(CLOCK_REALTIME, &end);
  dt = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
  return dt;
}

void set_implementation(char *selected) {
  auto my_implementation = simdjson::get_available_implementations()[selected];
  if(!my_implementation) { exit(1); }
  if(!my_implementation->supported_by_runtime_system()) { exit(1); }
  simdjson::get_active_implementation() = my_implementation;
}

/*
argv[1] implementation to use
  haswell: Intel/AMD AVX2
  westmere: Intel/AMD SSE4.2
  fallback: no optimizations
argv[2] json file to parse
  large-file.json: pulled from https://github.com/json-iterator/test-data
  twitter.json: built in with simdjson github repository
argv[3] number of iterations to test
*/
int main(int argc, char *argv[]) {
  set_implementation(argv[1]);
  std::string_view json_file{ argv[2] };
  std::string N_str { argv[3] };

  std::string json_str;
  for (std::string line; std::getline(std::cin, line);) {
    json_str += line;
  }
  std::string_view json_sv { json_str };

  argv[3] ? sscanf(N_str.data(), "%d", &N) : N = 1;
  for (int i = 0; i < N; i++) {
    double dt = parse(json_str);
    printf("%f\n", dt);
  }
  return 0;
}