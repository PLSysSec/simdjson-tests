#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string>
#include <iostream>
#include "simdjson.h"

#define BILLION 1000000000.0

using namespace simdjson;

void set_implementation(char *selected) {
  auto my_implementation = get_available_implementations()[selected];
  if(!my_implementation) { exit(1); }
  if(!my_implementation->supported_by_runtime_system()) { exit(1); }
  get_active_implementation() = my_implementation;
}

double parse(std::string_view json_sv) {
  struct timespec start, end;
  clock_gettime(CLOCK_REALTIME, &start);
  
  ondemand::parser parser; 
  padded_string json = padded_string(json_sv);
  ondemand::document doc = parser.iterate(json);

  clock_gettime(CLOCK_REALTIME, &end);
  double dt = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
  return dt;
}

/*
argv[1] implementation to use
  haswell: Intel/AMD AVX2
  westmere: Intel/AMD SSE4.2
  fallback: no optimizations
argv[2] number of iterations to test (default N = 1)
*/
int main(int argc, char *argv[]) {  
  std::cout << "Before setting Implementation" << std::endl;
  set_implementation(argv[1]);
  std::cout << "Implementation successfully set" << std::endl;
  std::string N_str { argv[2] };

  std::string json_str;
  for (std::string line; std::getline(std::cin, line);) {
    json_str += line;
  }
  std::string_view json_sv { json_str };

  int N;
  argv[2] ? sscanf(N_str.data(), "%d", &N) : N = 1;
  for (int i = 0; i < N; i++) {
    std::cout << parse(json_sv) << std::endl;
  }
  return 0;
}