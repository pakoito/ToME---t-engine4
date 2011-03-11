-- T-Engine4
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
	files { "../src/runner/*.c", "../src/getself.c", "../src/physfs.c", "../src/auxiliar.c" }
	links { "runner-physfs", "runner-lua", "m" }

	configuration "linux"
		links { "dl", "pthread" }
		defines { [[TENGINE_HOME_PATH='".t-engine"']], 'SELFEXE_LINUX'  }

	configuration "windows"
		defines { [[TENGINE_HOME_PATH='"T-Engine"']], 'SELFEXE_WINDOWS'  }
	configuration "macosx"
		defines { [[TENGINE_HOME_PATH='".t-engine"']], "USE_TENGINE_MAIN", 'SELFEXE_MACOSX'  }

	configuration {"Debug"}
		postbuildcommands { "cp ../bin/Debug/t-engine ../t-engine", }

	configuration {"Release"}
		postbuildcommands { "cp ../bin/Release/t-engine ../t-engine", }

project "runner-physfs"
	kind "StaticLib"
	language "C"
	targetname "runner-physfs"

	defines {"PHYSFS_SUPPORTS_ZIP"}

	files { "../src/physfs/*.c", "../src/physfs/zlib123/*.c", "../src/physfs/archivers/*.c", }

	configuration "linux"
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

	files { "../src/lua/*.c", }
