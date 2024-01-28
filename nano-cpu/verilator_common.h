
#include <string>

std::string get_vcd_path(int &argc, char **&argv) {
  std::string instructions_path;
  for (int idx = 0; idx < argc; idx++) {
    std::string str = std::string(argv[idx]);
    std::string find_str = "--vcd-path=";
    auto pos = str.find(find_str);
    if (pos == 0) {
      instructions_path = str.substr(find_str.length(), std::string::npos);
    }
  }
  return instructions_path;
}
