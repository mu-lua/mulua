#include "mulua-types.h"
#include "sol-nowarnings.h"
#include "version.cmake-out.h"
#include <cassert>
#include <format>
#include <iostream>
#include <print>
#include <string>

int main()
{
  std::print("Version :{}.{}.{}.{}\n", VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH, VERSION_TWEAK);
  return 0;
}
