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

-- capture the output of a command
function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

project "TEngine"
	kind "WindowedApp"
	language "C"
	targetname("t-engine")
	files { "../src/*.c", }
	if _OPTIONS.steam then
		files { "../steamworks/luasteam.c", }
	end
	links { "physfs", "lua".._OPTIONS.lua, "fov", "luasocket", "luaprofiler", "lpeg", "tcodimport", "lxp", "expatstatic", "luamd5", "luazlib", "luabitop", "te4-bzip" }
	defines { "_DEFAULT_VIDEOMODE_FLAGS_='SDL_HWSURFACE|SDL_DOUBLEBUF'" }
	defines { [[TENGINE_HOME_PATH='".t-engine"']], "TE4CORE_VERSION="..TE4CORE_VERSION }
	buildoptions { "-O3" }

	if _OPTIONS.relpath=="32" then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN/lib "} end
	if _OPTIONS.relpath=="64" then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN/lib64 "} end

	if _OPTIONS.relpath == "32" then defines{"TE4_RELPATH32"} end
	if _OPTIONS.relpath == "64" then defines{"TE4_RELPATH64"} end

	links { "m" }

	if _OPTIONS.no_rwops_size then defines{"NO_RWOPS_SIZE"} end

	if _OPTIONS.steam then
		dofile("../steamworks/build/steam-build.lua")
	end

	if _OPTIONS.wincross then
		prelinkcommands { "i686-pc-mingw32-ranlib ../bin/Debug/*.a" }
	end

	configuration "macosx"
		files { "../src/mac/SDL*" }
		includedirs {
			"/System/Library/Frameworks/OpenGL.framework/Headers",
			"/System/Library/Frameworks/OpenAL.framework/Headers",

			"/Library/Frameworks/SDL2.framework/Headers",
			"/Library/Frameworks/SDL2_image.framework/Headers",
			"/Library/Frameworks/SDL2_ttf.framework/Headers",
			"/Library/Frameworks/libpng.framework/Headers",
			"/Library/Frameworks/ogg.framework/Headers",
			"/Library/Frameworks/vorbis.framework/Headers",

			-- MacPorts paths
			"/opt/local/include",
			"/opt/local/include/Vorbis",

			-- Homebrew paths
			"/usr/local/include",
			"/usr/local/opt/libpng12/include",
		}
		defines { "USE_TENGINE_MAIN", 'SELFEXE_MACOSX', [[TENGINE_HOME_PATH='"/Library/Application Support/T-Engine/"']]  }
		linkoptions {
			"-framework Cocoa",
			"-framework OpenGL",
			"-framework OpenAL",

			"-framework SDL2",
			"-framework SDL2_image",
			"-framework SDL2_ttf",
			"-framework libpng",
			"-framework ogg",
			"-framework vorbis",
			"-Wl,-rpath,'@loader_path/../Frameworks'",
		}
		if _OPTIONS.lua == "jit2" then
			linkoptions {
				-- These two options are mandatory for LuaJIT to work
				"-pagezero_size 10000",
				"-image_base 100000000",
			}
		end
		targetdir "."
		links { "IOKit" }

	configuration "windows"
		links { "mingw32", "SDL2main", "SDL2", "SDL2_ttf", "SDL2_image", "OpenAL32", "vorbisfile", "opengl32", "glu32", "wsock32", "png" }
		defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS'  }
		if _OPTIONS.wincross then
			prebuildcommands { "/usr/bin/i686-pc-mingw32-windres ../src/windows/icon.rc -O coff -o ../src/windows/icon.res" }
		else
			prebuildcommands { "windres ../src/windows/icon.rc -O coff -o ../src/windows/icon.res" }
		end
		linkoptions { "../src/windows/icon.res" }
		linkoptions { "-mwindows" }
		defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS' }

	configuration "linux"
		libdirs {"/opt/SDL-2.0/lib/"}
		links { "dl", "SDL2", "SDL2_ttf", "SDL2_image", "png", "openal", "vorbisfile", "GL", "GLU", "m", "pthread" }
		linkoptions { "-Wl,-E" }
		defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_LINUX' }
		if steamlin64 then steamlin64() end

	configuration "bsd"
		libdirs {"/usr/local/lib/"}
		links { "SDL2", "SDL2_ttf", "SDL2_image", "png", "openal", "vorbisfile", "GL", "GLU", "m", "pthread" }
		defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_BSD' }

	configuration {"Debug"}
		if _OPTIONS.wincross then
			postbuildcommands { "cp ../bin/Debug/t-engine.exe ../", }
		else
			if os.get() ~= "macosx" then postbuildcommands { "cp ../bin/Debug/t-engine ../", }
			else postbuildcommands { "cp ../build/t-engine.app/Contents/MacOS/t-engine ../mac/base_app/Contents/MacOS", }
			end
		end
	configuration {"Release"}
		if _OPTIONS.wincross then
			postbuildcommands { "cp ../bin/Release/t-engine.exe ../", }
		else
			if os.get() ~= "macosx" then postbuildcommands { "cp ../bin/Release/t-engine ../", }
			else postbuildcommands { "cp ../build/t-engine.app/Contents/MacOS/t-engine ../mac/base_app/Contents/MacOS", }
			end
		end


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
	if _OPTIONS.no_rwops_size then defines{"NO_RWOPS_SIZE"} end

	files { "../src/physfs/*.c", "../src/zlib/*.c", "../src/physfs/archivers/*.c", }

	configuration "linux"
		files { "../src/physfs/platform/unix.c", "../src/physfs/platform/posix.c",  }
	configuration "bsd"
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
elseif _OPTIONS.lua == "jit2" then
	project "minilua"
		kind "ConsoleApp"
		language "C"
		targetname "minilua"
		links { "m" }
		if _OPTIONS.wincross then
			links {"mingw32"}
		end

		files { "../src/luajit2/src/host/minilua.c" }

		local arch_test
		if _OPTIONS.wincross then
			arch_test = os.capture("i686-pc-mingw32-gcc -E ../src/luajit2/src/lj_arch.h -dM", true)
		else
			arch_test = os.capture("gcc -E ../src/luajit2/src/lj_arch.h -dM", true)
		end

		if string.find(arch_test, "LJ_TARGET_X64") then
			target_arch = "x64"
		elseif string.find(arch_test, "LJ_TARGET_X86") then
			target_arch = "x86"
		elseif string.find(arch_test, "LJ_TARGET_ARM") then
			target_arch = "arm"
		elseif string.find(arch_test, "LJ_TARGET_PPC") then
			target_arch = "ppc"
		elseif string.find(arch_test, "LJ_TARGET_PPCSPE") then
			target_arch = "ppcspe"
		elseif string.find(arch_test, "LJ_TARGET_MIPS") then
			target_arch = "mips"
		else
			error("Unsupported target architecture, use architecture agnostic lua with --lua=default")
		end
		defines { "LUAJIT_TARGET=LUAJIT_ARCH_" .. target_arch }

		if string.find(arch_test, "LJ_ARCH_HASFPU 1") then
			defines { "LJ_ARCH_HASFPU=1" }
		else
			defines { "LJ_ARCH_HASFPU=0" }
		end
		if string.find(arch_test, "LJ_ABI_SOFTFP 1") then
			defines { "LJ_ABI_SOFTFP=1" }
		else
			defines { "LJ_ABI_SOFTFP=0" }
		end

		configuration {"Debug"}
			if _OPTIONS.wincross then
				postbuildcommands {
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Debug/minilua/minilua.cross.o" -c "../src/luajit2/src/host/minilua.c"',
					'gcc -o ../bin/Debug/minilua ../obj/Debug/minilua/minilua.cross.o  -m32 -L/usr/lib32 -L/Test/xcompile/local/lib   -lm',
				}
			end
			postbuildcommands { "cp ../bin/Debug/minilua ../src/luajit2/src/host/", }
		configuration {"Release"}
			if _OPTIONS.wincross then
				postbuildcommands {
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Release/minilua/minilua.cross.o" -c "../src/luajit2/src/host/minilua.c"',
					'gcc -o ../bin/Release/minilua ../obj/Release/minilua/minilua.cross.o  -m32 -L/usr/lib32 -L/Test/xcompile/local/lib   -lm',
				}
			end
			postbuildcommands { "cp ../bin/Release/minilua ../src/luajit2/src/host/", }

	project "buildvm"
		kind "ConsoleApp"
		language "C"
		targetname "buildvm"
		links { "minilua" }

		local dasm_flags = ""
		local arch_test
		if _OPTIONS.wincross then
			arch_test = os.capture("i686-pc-mingw32-gcc -E ../src/luajit2/src/lj_arch.h -dM", true)
		else
			arch_test = os.capture("gcc -E ../src/luajit2/src/lj_arch.h -dM", true)
		end

		if string.find(arch_test, "LJ_TARGET_X64") then
			target_arch = "x64"
		elseif string.find(arch_test, "LJ_TARGET_X86") then
			target_arch = "x86"
		elseif string.find(arch_test, "LJ_TARGET_ARM") then
			target_arch = "arm"
		elseif string.find(arch_test, "LJ_TARGET_PPC") then
			target_arch = "ppc"
		elseif string.find(arch_test, "LJ_TARGET_PPCSPE") then
			target_arch = "ppcspe"
		elseif string.find(arch_test, "LJ_TARGET_MIPS") then
			target_arch = "mips"
		else
			error("Unsupported target architecture, use architecture agnostic lua with --lua=default")
		end
		defines { "LUAJIT_TARGET=LUAJIT_ARCH_" .. target_arch }

		if string.find(arch_test, "LJ_ARCH_HASFPU 1") then
			defines { "LJ_ARCH_HASFPU=1" }
		else
			defines { "LJ_ARCH_HASFPU=0" }
		end
		if string.find(arch_test, "LJ_ABI_SOFTFP 1") then
			defines { "LJ_ABI_SOFTFP=1" }
		else
			defines { "LJ_ABI_SOFTFP=0" }
		end

		dasm_flags = dasm_flags .. " -D VER="

		if string.find(arch_test, "LJ_ARCH_BITS 64") then
			dasm_flags = dasm_flags .. " -D P64"
		end
		if string.find(arch_test, "LJ_HASJIT 1") then
			dasm_flags = dasm_flags .. " -D JIT"
		end
		if string.find(arch_test, "LJ_HASFFI 1") then
			dasm_flags = dasm_flags .. " -D FFI"
		end
		if string.find(arch_test, "LJ_DUALNUM 1") then
			dasm_flags = dasm_flags .. " -D DUALNUM"
		end
		if string.find(arch_test, "LJ_ARCH_HASFPU 1") then
			dasm_flags = dasm_flags .. " -D FPU"
		end
		if not string.find(arch_test, "LJ_ABI_SOFTFP 1") then
			dasm_flags = dasm_flags .. " -D HFABI"
		end
		if target_arch == "x86" and string.find(arch_test, "__SSE2__") then
			dasm_flags = dasm_flags .. " -D SSE"
		end
		if string.find(arch_test, "LJ_ARCH_SQRT 1") then
			dasm_flags = dasm_flags .. " -D SQRT"
		end
		if string.find(arch_test, "LJ_ARCH_ROUND 1") then
			dasm_flags = dasm_flags .. " -D ROUND"
		end
		if string.find(arch_test, "LJ_ARCH_PPC64 1") then
			dasm_flags = dasm_flags .. " -D GPR64"
		end

		if target_arch == "x64" then
			target_arch = "x86"
		end

		local dasc = "../src/luajit2/src/vm_" .. target_arch .. ".dasc"

		prebuildcommands{ "../src/luajit2/src/host/minilua ../src/luajit2/dynasm/dynasm.lua" .. dasm_flags .. " -o ../src/luajit2/src/host/buildvm_arch.h " .. dasc }

		files { "../src/luajit2/src/host/buildvm*.c" }

		configuration {"Debug"}
			if _OPTIONS.wincross then
				postbuildcommands {
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Debug/buildvm/buildvm_lib.cross.o" -c "../src/luajit2/src/host/buildvm_lib.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Debug/buildvm/buildvm_asm.cross.o" -c "../src/luajit2/src/host/buildvm_asm.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Debug/buildvm/buildvm_peobj.cross.o" -c "../src/luajit2/src/host/buildvm_peobj.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Debug/buildvm/buildvm_fold.cross.o" -c "../src/luajit2/src/host/buildvm_fold.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Debug/buildvm/buildvm.cross.o" -c "../src/luajit2/src/host/buildvm.c"',
					'gcc -o ../bin/Debug/buildvm ../obj/Debug/buildvm/buildvm_lib.cross.o ../obj/Debug/buildvm/buildvm_asm.cross.o ../obj/Debug/buildvm/buildvm_peobj.cross.o ../obj/Debug/buildvm/buildvm_fold.cross.o ../obj/Debug/buildvm/buildvm.cross.o  -m32 -L/usr/lib32 -L/Test/xcompile/local/lib',
				}
			end
			postbuildcommands { "cp ../bin/Debug/buildvm ../src/luajit2/src/", }
		configuration {"Release"}
			if _OPTIONS.wincross then
				postbuildcommands {
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Release/buildvm/buildvm_lib.cross.o" -c "../src/luajit2/src/host/buildvm_lib.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Release/buildvm/buildvm_asm.cross.o" -c "../src/luajit2/src/host/buildvm_asm.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Release/buildvm/buildvm_peobj.cross.o" -c "../src/luajit2/src/host/buildvm_peobj.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Release/buildvm/buildvm_fold.cross.o" -c "../src/luajit2/src/host/buildvm_fold.c"',
					'gcc -MMD -MP -DGLEW_STATIC -DLUAJIT_TARGET=LUAJIT_ARCH_x86 -DLJ_ARCH_HASFPU=1 -DLJ_ABI_SOFTFP=0 -I../src -I../src/luasocket -I../src/fov -I../src/expat -I../src/lxp -I../src/libtcod_import -I../src/physfs -I../src/zlib -I../src/bzip2 -I../src/luajit2/src -I../src/luajit2/dynasm -g -m32 -ggdb -o "../obj/Release/buildvm/buildvm.cross.o" -c "../src/luajit2/src/host/buildvm.c"',
					'gcc -o ../bin/Release/buildvm ../obj/Release/buildvm/buildvm_lib.cross.o ../obj/Release/buildvm/buildvm_asm.cross.o ../obj/Release/buildvm/buildvm_peobj.cross.o ../obj/Release/buildvm/buildvm_fold.cross.o ../obj/Release/buildvm/buildvm.cross.o  -m32 -L/usr/lib32 -L/Test/xcompile/local/lib',
				}
			end
			postbuildcommands { "cp ../bin/Release/buildvm ../src/luajit2/src/", }

	project "luajit2"
		kind "StaticLib"
		language "C"
		targetname "lua"
		links { "buildvm" }

		files { "../src/luajit2/src/*.c", "../src/luajit2/src/*.s", "../src/luajit2/src/lj_vm.s", "../src/luajit2/src/lj_bcdef.h", "../src/luajit2/src/lj_ffdef.h", "../src/luajit2/src/lj_ffdef.h", "../src/luajit2/src/lj_libdef.h", "../src/luajit2/src/lj_recdef.h", "../src/luajit2/src/lj_folddef.h" }
		excludes { "../src/luajit2/src/buildvm*.c", "../src/luajit2/src/luajit.c", "../src/luajit2/src/ljamalg.c" }

		configuration "linux"
			if not _OPTIONS["no-cleanup-jit2"] then
			local list = "../src/luajit2/src/lib_base.c ../src/luajit2/src/lib_math.c ../src/luajit2/src/lib_bit.c ../src/luajit2/src/lib_string.c ../src/luajit2/src/lib_table.c ../src/luajit2/src/lib_io.c ../src/luajit2/src/lib_os.c ../src/luajit2/src/lib_package.c ../src/luajit2/src/lib_debug.c ../src/luajit2/src/lib_jit.c ../src/luajit2/src/lib_ffi.c"
			prebuildcommands{
				"../src/luajit2/src/buildvm -m elfasm -o ../src/luajit2/src/lj_vm.s",
				"../src/luajit2/src/buildvm -m bcdef -o ../src/luajit2/src/lj_bcdef.h "..list,
				"../src/luajit2/src/buildvm -m ffdef -o ../src/luajit2/src/lj_ffdef.h "..list,
				"../src/luajit2/src/buildvm -m libdef -o ../src/luajit2/src/lj_libdef.h "..list,
				"../src/luajit2/src/buildvm -m recdef -o ../src/luajit2/src/lj_recdef.h "..list,
				"../src/luajit2/src/buildvm -m vmdef -o ../src/luajit2/vmdef.lua "..list,
				"../src/luajit2/src/buildvm -m folddef -o ../src/luajit2/src/lj_folddef.h ../src/luajit2/src/lj_opt_fold.c",
			}
			end

		configuration "bsd"
			if not _OPTIONS["no-cleanup-jit2"] then
			local list = "../src/luajit2/src/lib_base.c ../src/luajit2/src/lib_math.c ../src/luajit2/src/lib_bit.c ../src/luajit2/src/lib_string.c ../src/luajit2/src/lib_table.c ../src/luajit2/src/lib_io.c ../src/luajit2/src/lib_os.c ../src/luajit2/src/lib_package.c ../src/luajit2/src/lib_debug.c ../src/luajit2/src/lib_jit.c ../src/luajit2/src/lib_ffi.c"
			prebuildcommands{
				"../src/luajit2/src/buildvm -m elfasm -o ../src/luajit2/src/lj_vm.s",
				"../src/luajit2/src/buildvm -m bcdef -o ../src/luajit2/src/lj_bcdef.h "..list,
				"../src/luajit2/src/buildvm -m ffdef -o ../src/luajit2/src/lj_ffdef.h "..list,
				"../src/luajit2/src/buildvm -m libdef -o ../src/luajit2/src/lj_libdef.h "..list,
				"../src/luajit2/src/buildvm -m recdef -o ../src/luajit2/src/lj_recdef.h "..list,
				"../src/luajit2/src/buildvm -m vmdef -o ../src/luajit2/vmdef.lua "..list,
				"../src/luajit2/src/buildvm -m folddef -o ../src/luajit2/src/lj_folddef.h ../src/luajit2/src/lj_opt_fold.c",
			}
			end

		configuration "macosx"
			local list = "../src/luajit2/src/lib_base.c ../src/luajit2/src/lib_math.c ../src/luajit2/src/lib_bit.c ../src/luajit2/src/lib_string.c ../src/luajit2/src/lib_table.c ../src/luajit2/src/lib_io.c ../src/luajit2/src/lib_os.c ../src/luajit2/src/lib_package.c ../src/luajit2/src/lib_debug.c ../src/luajit2/src/lib_jit.c ../src/luajit2/src/lib_ffi.c"
			prebuildcommands{
				"../src/luajit2/src/buildvm -m machasm -o ../src/luajit2/src/lj_vm.s",
				"../src/luajit2/src/buildvm -m bcdef -o ../src/luajit2/src/lj_bcdef.h "..list,
				"../src/luajit2/src/buildvm -m ffdef -o ../src/luajit2/src/lj_ffdef.h "..list,
				"../src/luajit2/src/buildvm -m libdef -o ../src/luajit2/src/lj_libdef.h "..list,
				"../src/luajit2/src/buildvm -m recdef -o ../src/luajit2/src/lj_recdef.h "..list,
				"../src/luajit2/src/buildvm -m vmdef -o ../src/luajit2/vmdef.lua "..list,
				"../src/luajit2/src/buildvm -m folddef -o ../src/luajit2/src/lj_folddef.h ../src/luajit2/src/lj_opt_fold.c",
			}

		configuration "windows"
			if not _OPTIONS["no-cleanup-jit2"] then
			local list = "../src/luajit2/src/lib_base.c ../src/luajit2/src/lib_math.c ../src/luajit2/src/lib_bit.c ../src/luajit2/src/lib_string.c ../src/luajit2/src/lib_table.c ../src/luajit2/src/lib_io.c ../src/luajit2/src/lib_os.c ../src/luajit2/src/lib_package.c ../src/luajit2/src/lib_debug.c ../src/luajit2/src/lib_jit.c ../src/luajit2/src/lib_ffi.c"
			prebuildcommands{
				"../src/luajit2/src/buildvm -m coffasm -o ../src/luajit2/src/lj_vm.s",
				"../src/luajit2/src/buildvm -m bcdef -o ../src/luajit2/src/lj_bcdef.h "..list,
				"../src/luajit2/src/buildvm -m ffdef -o ../src/luajit2/src/lj_ffdef.h "..list,
				"../src/luajit2/src/buildvm -m libdef -o ../src/luajit2/src/lj_libdef.h "..list,
				"../src/luajit2/src/buildvm -m recdef -o ../src/luajit2/src/lj_recdef.h "..list,
				"../src/luajit2/src/buildvm -m vmdef -o ../src/luajit2/vmdef.lua "..list,
				"../src/luajit2/src/buildvm -m folddef -o ../src/luajit2/src/lj_folddef.h ../src/luajit2/src/lj_opt_fold.c",
			}
			end

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

project "te4-bzip"
	kind "StaticLib"
	language "C"
	targetname "te4-bzip"

	files { "../src/bzip2/*.c", }

if _OPTIONS['web-awesomium'] and not _OPTIONS.wincross then
project "te4-web"
	kind "SharedLib"
	language "C++"
	targetname "te4-web"

	libdirs {"/opt/awesomium/bin/"}
	includedirs {"/opt/awesomium/include/"}
	links { "awesomium-1-7" }
	
	files { "../src/web-awesomium/*.cpp", }
end

if _OPTIONS['web-cef3'] and not _OPTIONS.wincross then
project "te4-web"
	kind "SharedLib"
	language "C++"
	targetname "te4-web"

	if _OPTIONS.relpath=="32" then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN "} end
	if _OPTIONS.relpath=="64" then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN "} end

	files { "../src/web-cef3/*.cpp", }

	configuration "macosx"
		defines { 'SELFEXE_MACOSX' }
		libdirs {"/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/xcodebuild/Release/", "/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/Release/"}
		includedirs {"/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/include/", "/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/"}
		links { "cef", "cef_dll_wrapper" }

	configuration "windows"
		defines { 'SELFEXE_WINDOWS' }

	configuration "linux"
		buildoptions{"-Wall -pthread -I/usr/include/gtk-2.0 -I/usr/lib64/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng15 -I/usr/include/libdrm"}
		libdirs {"/opt/cef3/1547/out/Release/obj.target/", "/opt/cef3/1547/Release/"}
		includedirs {"/opt/cef3/1547/include/", "/opt/cef3/1547/"}
		links { "cef", "cef_dll_wrapper" }
		defines { 'SELFEXE_LINUX' }


project "cef3spawn"
	kind "WindowedApp"
	language "C++"
	targetname "cef3spawn"

	includedirs {"../src/web-cef3/", }
	files {
		"../src/web-cef3/spawn.cpp",
	}

	configuration "macosx"
		defines { 'SELFEXE_MACOSX' }
		libdirs {"/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/xcodebuild/Release/", "/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/Release/"}
		includedirs {"/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/include/", "/users/tomedev/downloads/cef_binary_3.1547.1597_macosx64/"}
		links { "cef", "cef_dll_wrapper" }

	configuration "linux"
		buildoptions{"-Wall -pthread -I/usr/include/gtk-2.0 -I/usr/lib64/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng15 -I/usr/include/libdrm"}
		libdirs {"/opt/cef3/1547/out/Release/obj.target/", "/opt/cef3/1547/Release/"}
		includedirs {"/opt/cef3/1547/include/", "/opt/cef3/1547/"}
		links { "cef", "cef_dll_wrapper" }
		if _OPTIONS.relpath=="32" then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN/lib "} end
		if _OPTIONS.relpath=="64" then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN/lib64 "} end
		defines { 'SELFEXE_LINUX' }
end

if _OPTIONS.steam then
	dofile("../steamworks/build/steam-code.lua")
end
