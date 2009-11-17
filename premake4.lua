solution "TEngine"
	configurations { "Debug", "Release" }
	objdir "obj"

	includedirs {
		"src",
		"src/lua",
		"src/fov",
		"physfs",
		"physfs/zlib123",
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
	links { "physfs", "lua", "fov" }

configuration "macosx"
	linkoptions { "mac/SDLmain.m", "-framework SDL", "-framework SDL_image", "-framework SDL_ttf", "-framework Cocoa" }
	files { "mac/SDL*" }
	targetdir "."

configuration "not macosx"
	links { "SDL", "SDL_ttf", "SDL_image" }


project "physfs"
	kind "StaticLib"
	language "C"
	targetname "physfs"

	files { "physfs/*.c", "physfs/archivers/*.c", }

	configuration "not macosx"
		files { "physfs/platform/unix.c", "physfs/platform/posix.c",  }
	configuration "macosx"
		files { "physfs/platform/macosx.c", "physfs/platform/posix.c",  }

project "lua"
	kind "StaticLib"
	language "C"
	targetname "lua"

	files { "src/lua/*.c", }

project "fov"
	kind "StaticLib"
	language "C"
	targetname "fov"

	files { "src/fov/*.c", }
