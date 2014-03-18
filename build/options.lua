-- T-Engine4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

TE4CORE_VERSION = 17
corename = "te4core-"..TE4CORE_VERSION

newoption {
	trigger     = "lua",
	value       = "VM_Type",
	description = "Virtual Machine to use for Lua, either the default one or a JIT",
	allowed = {
		{ "default",	"Default Lua Virtual Machine" },
		{ "jit2",	"LuaJIT2" },
	}
}
newoption {
	trigger     = "force32bits",
	description = "Forces compilation in 32bits mode, allowing to use the lua jit",
}
newoption {
	trigger     = "relpath",
	description = "Links libraries relative to the application path for redistribution",
}
newoption {
	trigger     = "luaassert",
	description = "Enable lua asserts to debug lua C code",
}
newoption {
	trigger     = "pedantic",
	description = "Enables compiling with all pedantic options",
}

newoption {
	trigger     = "no-cleanup-jit2",
	description = "Doesnt remove jit2 build files",
}

newoption {
	trigger	    = "no_rwops_size",
	description = "Compat for old SDL2 dev verions"
}

newoption {
	trigger	    = "steam",
	description = "Steam integration"
}

newoption {
	trigger	    = "wincross",
	description = "Enables cross-compilation for windows (from linux)"
}

_OPTIONS.lua = _OPTIONS.lua or "jit2"
