#include <iostream>
#include <fstream>
#include <time.h>
#include "simdjson.h"

#define BILLION 1000000000.0

using namespace simdjson;

double parse(char *json_file) {
  struct timespec start, end;
  double dt;
  clock_gettime(CLOCK_REALTIME, &start);

  ondemand::parser parser;
  padded_string json = padded_string::load(json_file);
  ondemand::document tweets = parser.iterate(json);

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
argv[3] output file to export execution speed (optional)
*/
int main(int argc, char *argv[]) {
  set_implementation(argv[1]);
  double dt = parse(argv[2]);

  const char* env_p = std::getenv("wasm");
  std::cout << env_p << std::endl;

  if (argc > 3) {
    std::ofstream out(argv[3], std::ios_base::app);
    out << dt << "\n";
    out.close();
  }

  return 0;
}