dofile("build/options.lua")

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


--dofile("build/runner.lua")
dofile("build/te4core.lua")
