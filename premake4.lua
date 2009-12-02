solution "TEngine"
	configurations { "Debug", "Release" }
	objdir "obj"

	includedirs {
		"src",
		"src/lua",
		"src/luasocket",
		"src/fov",
		"src/physfs",
		"src/physfs/zlib123",
		"/usr/include/SDL",
	}

	libdirs {
	}

configuration "Debug"
	defines { }
	flags { "Symbols" }
	buildoptions { "-ggdb" }
	targetdir "bin/Debug"

configuration "Release"
	defines { "NDEBUG=1" }
	flags { "Optimize" }
	buildoptions { "-O2" }
	targetdir "bin/Release"

project "TEngine"
	kind "WindowedApp"
	language "C"
	targetname "t-engine"
	files { "src/*.c", }
	links { "physfs", "lua", "fov", "luasocket", "luaprofiler" }
	defines { "_DEFAULT_VIDEOMODE_FLAGS_='SDL_HWSURFACE|SDL_DOUBLEBUF'" }
	defines { [[TENGINE_HOME_PATH='".t-engine"']] }

configuration "macosx"
	linkoptions { "mac/SDLmain.m", "-framework SDL", "-framework SDL_gfx", "-framework SDL_image", "-framework SDL_ttf", "-framework SDL_mixer", "-framework Cocoa" }
	files { "mac/SDL*" }
	targetdir "."

configuration "not macosx"
	links { "SDL", "SDL_ttf", "SDL_image", "SDL_gfx", "SDL_mixer" }

configuration "windows"
	defines { [[TENGINE_HOME_PATH='"T-Engine"']] }


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

project "lua"
	kind "StaticLib"
	language "C"
	targetname "lua"

	files { "src/lua/*.c", }

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

project "luaprofiler"
	kind "StaticLib"
	language "C"
	targetname "luaprofiler"

	files { "src/luaprofiler/*.c", }
