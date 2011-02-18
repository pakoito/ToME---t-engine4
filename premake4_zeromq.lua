zeromq_dir			=	"src/zeromq"
--zeromq_path			=	path.join( os.getcwd(), "../" .. zeromq_dir )
zeromq_path = zeromq_dir

--
zeromq_files =
{
--	"zeromq_project.lua",

	zeromq_path .. "/src/*.hpp",
	zeromq_path .. "/src/*.cpp",

	zeromq_path .. "/include/zmq.h",
	zeromq_path .. "/include/zmq.hpp",
}

project "te4zmq"
	targetname "te4zmq"
	language		"C++"
	kind			"StaticLib"
	includedirs		{ zeromq_path .. "/include" }
	defines			{ "ZMQ_STATIC" }
	files			( zeromq_files )

	configuration "linux"
		defines {"ZMQ_HAVE_LINUX"}

	configuration "macosx"
		defines {"ZMQ_HAVE_OSX"}

	configuration "windows"
		defines {"ZMQ_HAVE_WINDOWS"}
		prebuildcommands	{ "copy \"" .. zeromq_path .. "\\builds\\msvc\\platform.hpp\" \"" .. zeromq_path .. "\\src\\platform.hpp\"" }
