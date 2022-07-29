#include <iostream>
#include <time.h>
#include "simdjson.h"

#define BILLION 1000000000.0

using namespace simdjson;

double parse(bool timed) {
  struct timespec start, end;
  double dt = 0;
  if (timed) {
    clock_gettime(CLOCK_REALTIME, &start);
  }

  ondemand::parser parser;
  padded_string json = padded_string::load("twitter.json");
  ondemand::document tweets = parser.iterate(json);

  if (timed) {
    clock_gettime(CLOCK_REALTIME, &end);
    dt = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / BILLION;
  }
  return dt;
}

void set_implementation(char *selected) {
  auto my_implementation = simdjson::get_available_implementations()[selected];
  if(!my_implementation) { exit(1); }
  if(!my_implementation->supported_by_runtime_system()) { exit(1); }
  simdjson::get_active_implementation() = my_implementation;
}

int main(int argc, char *argv[]) {
  if (argc > 1) {
    set_implementation(argv[1]);
  }

  if (argc > 2) {
    parse(true);
  } else {
    parse (false);
  }
  
}