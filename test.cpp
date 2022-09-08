#include <iostream>
#include <string>

int main() {
    std::string json_str;
    for (std::string line; std::getline(std::cin, line);) {
        json_str += line;
    }
    std::cout << json_str << std::endl;
    std::cout << json_str.length() << std::endl;
}
