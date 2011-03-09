-- This file is the very first lua file loaded
-- It will be called before anything else is setup, including paths
-- Usualy it will be put inside a zip that is concatenated to the executable itself

print("Booting T-Engine from: "..tostring(__SELFEXE))

-- Mount the engine, either from a path guessed from SELFEXE, or directly from current dir
if __SELFEXE then
	local dir = __SELFEXE

	-- Remove bin/Debug from the path, to make dev easier
	dir = dir:gsub("bin"..fs.getPathSeparator().."Debug"..fs.getPathSeparator(), "")

	if not __APPLE__ then
		-- Now remove executable name
		dir = dir:gsub("(.*"..fs.getPathSeparator()..").+", "%1")
	end

	print("SelfExe gave us app directory of:", dir)
	fs.mount(dir..fs.getPathSeparator().."game"..fs.getPathSeparator().."thirdparty", "/", true)
	fs.mount(dir..fs.getPathSeparator().."game", "/", true)
else
	fs.mount("game"..fs.getPathSeparator().."thirdparty", "/", true)
	fs.mount("game", "/", true)
end

-- Look for a core
function get_core(id)
	for i, file in ipairs(fs.list("/engines/cores/")) do
		if file:find("%.tec$") then
			print("Possible engine core", file)
		end
	end
	local core = "/engines/cores/te4core-"..id..".tec"
	if fs.exists(core) then
		local rcore = fs.getRealPath(core)
		print("Using TE4CORE: ", core, rcore)
		return rcore
	end
	return "NO CORE"
end

-- We need it no more, lets forget about it just it case some malovelant script tried something silly
__SELFEXE = nil
