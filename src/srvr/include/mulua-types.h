#pragma once
#ifndef MULUA_GUARD_TYPES_H
#define MULUA_GUARD_TYPES_H

#include <cstdint>
#include <string>
#include <string_view>

namespace mulua
{
typedef std::int8_t I8;
typedef std::int16_t I16;
typedef std::int32_t I32;
typedef std::int64_t I64;

typedef std::uint8_t U8;
typedef std::uint16_t U16;
typedef std::uint32_t U32;
typedef std::uint64_t U64;

typedef float F32;
typedef double F64;

typedef std::size_t SZ;

typedef std::string STR;
typedef std::string_view SV;
typedef std::wstring WSTR;
typedef std::wstring_view WSV;
typedef std::basic_string<char8_t> UTF8;
typedef std::basic_string_view<char8_t> UTF8V;
typedef std::basic_string<char16_t> UTF16;
typedef std::basic_string_view<char16_t> UTF16V;
typedef std::basic_string<char32_t> UTF32;
typedef std::basic_string_view<char32_t> UTF32V;

} // namespace mulua

#endif //MULUA_GUARD_TYPES_H
