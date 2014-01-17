/*
    TE4 - T-Engine 4
    Copyright (C) 2009 - 2014 Nicolas Casalini

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Nicolas Casalini "DarkGod"
    darkgod@te4.org
*/
#ifndef TYPES_H
#define TYPES_H

#ifndef __cplusplus
#ifndef bool
typedef char bool;
#endif
#endif

#define FALSE 0
#define TRUE 1

#ifndef ALWAYS_INLINE
#ifdef __GNUC__
#define ALWAYS_INLINE __attribute__((always_inline))
#else
#define ALWAYS_INLINE
#endif
#endif

extern bool no_debug;
extern int noprint(lua_State *L);
#ifdef REWRITE_PRINTF
#define printf(...) { if (!no_debug) printf(__VA_ARGS__); }
#endif

#endif
