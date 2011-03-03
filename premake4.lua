newoption {
	trigger     = "lua",
	value       = "VM_Type",
	description = "Virtual Machine to use for Lua, either the default one or a JIT",
	allowed = {
		{ "default",	"Default Lua Virtual Machine" },
		{ "jitx86",	"LuaJIT x86" },
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

_OPTIONS.lua = _OPTIONS.lua or "default"

solution "TEngine"
	configurations { "Debug", "Release" }
	objdir "obj"
	defines {"GLEW_STATIC"}
	if _OPTIONS.force32bits then buildoptions{"-m32"} linkoptions{"-m32"} libdirs{"/usr/lib32"} end
	if _OPTIONS.relpath then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN/lib "} end

	includedirs {
		"src",
		"src/luasocket",
		"src/fov",
		"src/expat",
		"src/lxp",
		"src/libtcod_import",
		"src/physfs",
		"src/physfs/zlib123",
		"/usr/include/SDL",
		"/usr/include/GL",
	}
	if _OPTIONS.lua == "default" then includedirs{"src/lua"}
	elseif _OPTIONS.lua == "jitx86" then includedirs{"src/luajit", "src/dynasm",}
	elseif _OPTIONS.lua == "jit2" then includedirs{"src/luajit2/src", "src/luajit2/dynasm",}
	end

	libdirs {
	}

configuration "windows"
	libdirs {
		"/e/libs/SDL-1.2.14/lib",
		"/e/libs/SDL_ttf-2.0.9/lib",
		"/e/libs/SDL_image-1.2.10/lib",
		"/e/libs/SDL_mixer-1.2.11/lib",
		"/e/apps/mingw/lib",
	}
	includedirs {
		"/e/libs/SDL-1.2.14/include/SDL",
		"/e/libs/SDL_ttf-2.0.9/include/",
		"/e/libs/SDL_image-1.2.10/include/",
		"/e/libs/SDL_mixer-1.2.11/include/",
		"/e/apps/mingw/include/GL",
	}

configuration "Debug"
	defines { }
	flags { "Symbols" }
	buildoptions { "-ggdb" }
	targetdir "bin/Debug"
	if _OPTIONS.luaassert then defines {"LUA_USE_APICHECK"} end
	if _OPTIONS.pedantic then buildoptions { "-Wall" } end

configuration "Release"
	defines { "NDEBUG=1" }
	flags { "Optimize", "NoFramePointer" }
	buildoptions { "-O3" }
	targetdir "bin/Release"

project "TEngine"
	kind "WindowedApp"
	language "C"
	targetname "t-engine"
	files { "src/*.c", }
	links { "physfs", "lua".._OPTIONS.lua, "fov", "luasocket", "luaprofiler", "lualanes", "lpeg", "tcodimport", "lxp", "expatstatic", "luamd5", "luazlib" }
	defines { "_DEFAULT_VIDEOMODE_FLAGS_='SDL_HWSURFACE|SDL_DOUBLEBUF'" }
	defines { [[TENGINE_HOME_PATH='".t-engine"']] }

configuration "macosx"
	linkoptions { "-framework SDL", "-framework SDL_image", "-framework SDL_ttf", "-framework SDL_mixer", "-framework Cocoa", "-framework OpenGL" }
	files { "src/mac/SDL*" }
        links { "IOKit" }
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
	prebuildcommands { "windres src/windows/icon.rc -O coff -o src/windows/icon.res" } 
	linkoptions { "src/windows/icon.res" }


configuration "linux"
	links { "SDL", "SDL_ttf", "SDL_image", "SDL_mixer", "GL", "GLU", "m", "pthread" }
	defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_LINUX' }

configuration {"linux", "Debug"}
	postbuildcommands { "cp bin/Debug/t-engine t-engine", }
configuration {"linux", "Release"}
	postbuildcommands { "cp bin/Release/t-engine t-engine", }


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

	files { "src/physfs/*.c", "src/physfs/zlib123/*.c", "src/physfs/archivers/*.c", }

	configuration "linux"
		files { "src/physfs/platform/unix.c", "src/physfs/platform/posix.c",  }
	configuration "windows"
		files { "src/physfs/platform/windows.c",  }
	configuration "macosx"
		files { "src/physfs/platform/macosx.c", "src/physfs/platform/posix.c",  }
                includedirs { "/Library/Frameworks/SDL.framework/Headers" }

if _OPTIONS.lua == "default" then
	project "luadefault"
		kind "StaticLib"
		language "C"
		targetname "lua"

		files { "src/lua/*.c", }
elseif _OPTIONS.lua == "jitx86" then
	project "luajitx86"
		kind "StaticLib"
		language "C"
		targetname "lua"

		files { "src/luajit/*.c", }
		configuration "linux"
			defines { "LUA_USE_POSIX" }
elseif _OPTIONS.lua == "jit2" then
	project "luajit2"
		kind "StaticLib"
		language "C"
		targetname "lua"

		files { "src/luajit2/src/*.c", "src/luajit2/src/*.s", }
--		configuration "linux"
--			defines { "LUA_USE_POSIX" }
end

project "luasocket"
	kind "StaticLib"
	language "C"
	targetname "luasocket"

	configuration "not windows"
		files {
			"src/luasocket/auxiliar.c",
			"src/luasocket/buffer.c",
			"src/luasocket/except.c",
			"src/luasocket/inet.c",
			"src/luasocket/io.c",
			"src/luasocket/luasocket.c",
			"src/luasocket/options.c",
			"src/luasocket/select.c",
			"src/luasocket/tcp.c",
			"src/luasocket/timeout.c",
			"src/luasocket/udp.c",
			"src/luasocket/usocket.c",
			"src/luasocket/mime.c",
		}
	configuration "windows"
		files {
			"src/luasocket/auxiliar.c",
			"src/luasocket/buffer.c",
			"src/luasocket/except.c",
			"src/luasocket/inet.c",
			"src/luasocket/io.c",
			"src/luasocket/luasocket.c",
			"src/luasocket/options.c",
			"src/luasocket/select.c",
			"src/luasocket/tcp.c",
			"src/luasocket/timeout.c",
			"src/luasocket/udp.c",
			"src/luasocket/wsocket.c",
			"src/luasocket/mime.c",
		}

project "fov"
	kind "StaticLib"
	language "C"
	targetname "fov"

	files { "src/fov/*.c", }

project "lpeg"
	kind "StaticLib"
	language "C"
	targetname "lpeg"

	files { "src/lpeg/*.c", }

project "luaprofiler"
	kind "StaticLib"
	language "C"
	targetname "luaprofiler"

	files { "src/luaprofiler/*.c", }

project "lualanes"
	kind "StaticLib"
	language "C"
	targetname "lualanes"

	files { "src/lualanes/*.c", }

project "tcodimport"
	kind "StaticLib"
	language "C"
	targetname "tcodimport"

	files { "src/libtcod_import/*.c", }

project "expatstatic"
	kind "StaticLib"
	language "C"
	targetname "expatstatic"
	defines{ "HAVE_MEMMOVE" }

	files { "src/expat/*.c", }

project "lxp"
	kind "StaticLib"
	language "C"
	targetname "lxp"

	files { "src/lxp/*.c", }

project "luamd5"
	kind "StaticLib"
	language "C"
	targetname "luamd5"

	files { "src/luamd5/*.c", }

project "luazlib"
	kind "StaticLib"
	language "C"
	targetname "luazlib"

	files { "src/lzlib/*.c", }
