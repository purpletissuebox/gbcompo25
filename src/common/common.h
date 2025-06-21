#pragma once

#include <stdint.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef int8_t s8;
typedef int16_t s16;

extern u8 __at(0xFFFE) scratch;

#define DEBUG 0
