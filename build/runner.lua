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

project "TEngineRunner"
	kind "WindowedApp"
	language "C"
	targetname "t-engine"
	files { "../src/runner/main.c", "../src/getself.c" }
	links { "m" }

	configuration "linux"
		links { "dl", "SDL", "SDL_ttf", "SDL_image", "SDL_mixer", "GL", "GLU", "m", "pthread" }
		defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_LINUX'  }

	configuration "bsd"
		links { "SDL", "SDL_ttf", "SDL_image", "SDL_mixer", "GL", "GLU", "m", "pthread" }
		defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_BSD'  }

	configuration "windows"
		links { "mingw32", "SDLmain", "SDL", "SDL_ttf", "SDL_image", "SDL_mixer", "OPENGL32", "GLU32", "wsock32" }
		defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS'  }
		prebuildcommands { "windres ../src/windows/icon.rc -O coff -o ../src/windows/icon.res" }
		linkoptions { "../src/windows/icon.res" }

	configuration "macosx"
		defines { [[TENGINE_HOME_PATH='".t-engine"']], "USE_TENGINE_MAIN", 'SELFEXE_MACOSX'  }
		linkoptions { "-framework SDL", "-framework SDL_image", "-framework SDL_ttf", "-framework SDL_mixer", "-framework Cocoa", "-framework OpenGL" }
        	links { "IOKit" }

	configuration {"Debug"}
		postbuildcommands { "cp ../bin/Debug/t-engine ../t-engine", }
	configuration {"Release"}
		postbuildcommands { "cp ../bin/Release/t-engine ../t-engine", }

project "te4runner"
	kind "SharedLib"
	language "C"
	targetname "te4runner"
	targetprefix ""
	targetextension ".tec"

	files { "../src/runner/runner.c", "../src/physfs.c", "../src/auxiliar.c" }
	links { "runner-physfs", "runner-lua", "m" }

	configuration "linux"
		defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_LINUX'  }
	configuration "bsd"
		defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_BSD'  }

	configuration "windows"
		defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS'  }
	configuration "macosx"
		defines { [[TENGINE_HOME_PATH='".t-engine"']], "USE_TENGINE_MAIN", 'SELFEXE_MACOSX'  }

	configuration {"Debug"}
		postbuildcommands { "cp ../bin/Debug/te4runner.tec ../", }
	configuration {"Release"}
		postbuildcommands { "cp ../bin/Release/te4runner.tec ../", }

project "runner-physfs"
	kind "StaticLib"
	language "C"
	targetname "runner-physfs"
	buildoptions { "-fPIC" }

	defines {"PHYSFS_SUPPORTS_ZIP"}

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

project "runner-lua"
	kind "StaticLib"
	language "C"
	targetname "runner-lua"
	buildoptions { "-fPIC" }

	files { "../src/lua/*.c", }
