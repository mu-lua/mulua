/* Required due to header bugs in SOL/LUA libraries*/
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreserved-macro-identifier"
#undef __GNUC__
#undef __MINGW32__
// #define __clang__ 1
// #undef _MSC_VER
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
#include <sol/sol.hpp>
#pragma clang diagnostic pop
