#ifndef MACCONFIG_H
#define MACCONFIG_H

#include <libkern/OSByteOrder.h>

/* 1234 = LIL_ENDIAN, 4321 = BIGENDIAN */
/* whether byteorder is bigendian */
#ifdef __LITTLE_ENDIAN__
#define BYTEORDER  1234
#define WORDS_LITTLEENDIAN
#elif defined __BIG_ENDIAN__
#define WORDS_BIGENDIAN
#define BYTEORDER  4321
#endif

#define HAVE_BCOPY
#define HAVE_MEMMOVE
#define HAVE_MMAP
#define HAVE_UNISTD_H

#endif /* ifndef MACCONFIG_H */
