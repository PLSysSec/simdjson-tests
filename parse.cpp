#include <iostream>
#include <atomic>
#include "simdjson.h"

using namespace simdjson;

void set_implementation(char *selected) {
  auto my_implementation = simdjson::get_available_implementations()[selected];
  if(!my_implementation) { exit(1); }
  if(!my_implementation->supported_by_runtime_system()) { exit(1); }
  simdjson::get_active_implementation() = my_implementation;
  // std::cout << simdjson::get_active_implementation()->name() 
  //   << " (" << simdjson::get_active_implementation()->description() << ")" << std::endl;
}

int main(int argc, char *argv[]) {
  if (argc > 1) {
    set_implementation(argv[1]);
  }

  ondemand::parser parser;
  padded_string json = padded_string::load("twitter.json");
  ondemand::document tweets = parser.iterate(json);
  std::cout << uint64_t(tweets["search_metadata"]["count"]) << " results." << std::endl;
  
}