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
	kind "WindowedApp"
	language "C"
	targetname("t-engine-")
	files { "../src/*.c", }
	links { "physfs", "lua".._OPTIONS.lua, "fov", "luasocket", "luaprofiler", "lualanes", "lpeg", "tcodimport", "lxp", "expatstatic", "luamd5", "luazlib", "luabitop" }
	defines { "_DEFAULT_VIDEOMODE_FLAGS_='SDL_HWSURFACE|SDL_DOUBLEBUF'" }
	defines { [[TENGINE_HOME_PATH='".t-engine"']], "TE4CORE_VERSION="..TE4CORE_VERSION }

	links { "m" }

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
		linkoptions { "-framework SDL", "-framework SDL_image", "-framework SDL_ttf", "-framework SDL_mixer", "-framework Cocoa", "-framework OpenGL" }
		targetdir "."
        	links { "IOKit" }

	configuration "windows"
		links { "mingw32", "SDLmain", "SDL", "SDL_ttf", "SDL_image", "SDL_mixer", "OPENGL32", "GLU32", "wsock32" }
		defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS'  }
		prebuildcommands { "windres ../src/windows/icon.rc -O coff -o ../src/windows/icon.res" }
		linkoptions { "../src/windows/icon.res" }
		linkoptions { "-mwindows" }
		defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS' }


	configuration "linux"
		links { "dl", "SDL", "SDL_ttf", "SDL_image", "SDL_mixer", "GL", "GLU", "m", "pthread" }
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

		files { "../src/lua/*.c", }
elseif _OPTIONS.lua == "jitx86" then
	project "luajitx86"
		kind "StaticLib"
		language "C"
		targetname "lua"

		files { "../src/luajit/*.c", }
		configuration "linux"
			defines { "LUA_USE_POSIX" }
elseif _OPTIONS.lua == "jit2" then
	project "luajit2"
		kind "StaticLib"
		language "C"
		targetname "lua"

		files { "../src/luajit2/src/*.c", "../src/luajit2/src/*.s", }
--		configuration "linux"
--			defines { "LUA_USE_POSIX" }
end

project "luasocket"
	kind "StaticLib"
	language "C"
	targetname "luasocket"

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

	files { "../src/fov/*.c", }

project "lpeg"
	kind "StaticLib"
	language "C"
	targetname "lpeg"

	files { "../src/lpeg/*.c", }

project "luaprofiler"
	kind "StaticLib"
	language "C"
	targetname "luaprofiler"

	files { "../src/luaprofiler/*.c", }

project "lualanes"
	kind "StaticLib"
	language "C"
	targetname "lualanes"

	files { "../src/lualanes/*.c", }

project "tcodimport"
	kind "StaticLib"
	language "C"
	targetname "tcodimport"

	files { "../src/libtcod_import/*.c", }

project "expatstatic"
	kind "StaticLib"
	language "C"
	targetname "expatstatic"
	defines{ "HAVE_MEMMOVE" }

	files { "../src/expat/*.c", }

project "lxp"
	kind "StaticLib"
	language "C"
	targetname "lxp"

	files { "../src/lxp/*.c", }

project "luamd5"
	kind "StaticLib"
	language "C"
	targetname "luamd5"

	files { "../src/luamd5/*.c", }

project "luazlib"
	kind "StaticLib"
	language "C"
	targetname "luazlib"

	files { "../src/lzlib/*.c", }

project "luabitop"
	kind "StaticLib"
	language "C"
	targetname "luabitop"

	files { "../src/luabitop/*.c", }
