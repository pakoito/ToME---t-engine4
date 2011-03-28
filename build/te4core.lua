-- T-Engine4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

project "TEngine"
	targetprefix ""
	targetextension ".tec"
	kind "SharedLib"
	language "C"
	targetname(corename)
	files { "../src/*.c", }
	links { "physfs", "lua".._OPTIONS.lua, "fov", "luasocket", "luaprofiler", "lualanes", "lpeg", "tcodimport", "lxp", "expatstatic", "luamd5", "luazlib", "luabitop" }
	defines { "_DEFAULT_VIDEOMODE_FLAGS_='SDL_HWSURFACE|SDL_DOUBLEBUF'" }
	defines { [[TENGINE_HOME_PATH='".t-engine"']], "TE4CORE_VERSION="..TE4CORE_VERSION }

configuration "macosx"
	files { "../src/mac/SDL*" }
        includedirs {
              "/System/Library/Frameworks/OpenGL.framework/Headers",
              "/Library/Frameworks/SDL.framework/Headers",
              "/Library/Frameworks/SDL_net.framework/Headers",
              "/Library/Frameworks/SDL_image.framework/Headers",
              "/Library/Frameworks/SDL_ttf.framework/Headers",
              "/Library/Frameworks/SDL_mixer.framework/Headers"
        }
        defines { "USE_TENGINE_MAIN", 'SELFEXE_MACOSX'  }
	targetdir "."

configuration "windows"
	linkoptions { "-mwindows" }
	links { "mingw32", "SDLmain", "SDL", "SDL_ttf", "SDL_image", "SDL_mixer", "OPENGL32", "GLU32", "wsock32" }
	defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS' }


configuration "linux"
	buildoptions { "-fPIC" }
	defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_LINUX' }

configuration {"Debug"}
	postbuildcommands { "cp ../bin/Debug/"..corename.."* ../game/engines/cores/", }
configuration {"Release"}
	postbuildcommands { "cp ../bin/Release/"..corename.."* ../game/engines/cores/", }


----------------------------------------------------------------
----------------------------------------------------------------
-- Librairies used by T-Engine
----------------------------------------------------------------
----------------------------------------------------------------
project "physfs"
	kind "StaticLib"
	language "C"
	targetname "physfs"
	buildoptions { "-fPIC" }

	defines {"PHYSFS_SUPPORTS_ZIP"}

	files { "../src/physfs/*.c", "../src/physfs/zlib123/*.c", "../src/physfs/archivers/*.c", }

	configuration "linux"
		files { "../src/physfs/platform/unix.c", "../src/physfs/platform/posix.c",  }
	configuration "windows"
		files { "../src/physfs/platform/windows.c",  }
	configuration "macosx"
		files { "../src/physfs/platform/macosx.c", "../src/physfs/platform/posix.c",  }
                includedirs { "/Library/Frameworks/SDL.framework/Headers" }

if _OPTIONS.lua == "default" then
	project "luadefault"
		kind "StaticLib"
		language "C"
		targetname "lua"
		buildoptions { "-fPIC" }

		files { "../src/lua/*.c", }
elseif _OPTIONS.lua == "jitx86" then
	project "luajitx86"
		kind "StaticLib"
		language "C"
		targetname "lua"
		buildoptions { "-fPIC" }

		files { "../src/luajit/*.c", }
		configuration "linux"
			defines { "LUA_USE_POSIX" }
elseif _OPTIONS.lua == "jit2" then
	project "luajit2"
		kind "StaticLib"
		language "C"
		targetname "lua"
		buildoptions { "-fPIC" }

		files { "../src/luajit2/src/*.c", "../src/luajit2/src/*.s", }
--		configuration "linux"
--			defines { "LUA_USE_POSIX" }
end

project "luasocket"
	kind "StaticLib"
	language "C"
	targetname "luasocket"
	buildoptions { "-fPIC" }

	configuration "not windows"
		files {
			"../src/luasocket/auxiliar.c",
			"../src/luasocket/buffer.c",
			"../src/luasocket/except.c",
			"../src/luasocket/inet.c",
			"../src/luasocket/io.c",
			"../src/luasocket/luasocket.c",
			"../src/luasocket/options.c",
			"../src/luasocket/select.c",
			"../src/luasocket/tcp.c",
			"../src/luasocket/timeout.c",
			"../src/luasocket/udp.c",
			"../src/luasocket/usocket.c",
			"../src/luasocket/mime.c",
		}
	configuration "windows"
		files {
			"../src/luasocket/auxiliar.c",
			"../src/luasocket/buffer.c",
			"../src/luasocket/except.c",
			"../src/luasocket/inet.c",
			"../src/luasocket/io.c",
			"../src/luasocket/luasocket.c",
			"../src/luasocket/options.c",
			"../src/luasocket/select.c",
			"../src/luasocket/tcp.c",
			"../src/luasocket/timeout.c",
			"../src/luasocket/udp.c",
			"../src/luasocket/wsocket.c",
			"../src/luasocket/mime.c",
		}

project "fov"
	kind "StaticLib"
	language "C"
	targetname "fov"
	buildoptions { "-fPIC" }

	files { "../src/fov/*.c", }

project "lpeg"
	kind "StaticLib"
	language "C"
	targetname "lpeg"
	buildoptions { "-fPIC" }

	files { "../src/lpeg/*.c", }

project "luaprofiler"
	kind "StaticLib"
	language "C"
	targetname "luaprofiler"
	buildoptions { "-fPIC" }

	files { "../src/luaprofiler/*.c", }

project "lualanes"
	kind "StaticLib"
	language "C"
	targetname "lualanes"
	buildoptions { "-fPIC" }

	files { "../src/lualanes/*.c", }

project "tcodimport"
	kind "StaticLib"
	language "C"
	targetname "tcodimport"
	buildoptions { "-fPIC" }

	files { "../src/libtcod_import/*.c", }

project "expatstatic"
	kind "StaticLib"
	language "C"
	targetname "expatstatic"
	defines{ "HAVE_MEMMOVE" }
	buildoptions { "-fPIC" }

	files { "../src/expat/*.c", }

project "lxp"
	kind "StaticLib"
	language "C"
	targetname "lxp"
	buildoptions { "-fPIC" }

	files { "../src/lxp/*.c", }

project "luamd5"
	kind "StaticLib"
	language "C"
	targetname "luamd5"
	buildoptions { "-fPIC" }

	files { "../src/luamd5/*.c", }

project "luazlib"
	kind "StaticLib"
	language "C"
	targetname "luazlib"
	buildoptions { "-fPIC" }

	files { "../src/lzlib/*.c", }

project "luabitop"
	kind "StaticLib"
	language "C"
	targetname "luabitop"
	buildoptions { "-fPIC" }

	files { "../src/luabitop/*.c", }
