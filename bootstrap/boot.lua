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
	if fs.exists("/engine.teae") and fs.exists("/thirdparty.teae") then
		fs.mount(dir..fs.getPathSeparator().."game/engine.teae", "/", true)
		fs.mount(dir..fs.getPathSeparator().."game/thirdparty.teae", "/", true)
		print("Using engine.teae")
	end
else
	fs.mount("game"..fs.getPathSeparator().."thirdparty", "/", true)
	fs.mount("game", "/", true)
	if fs.exists("/engine.teae") and fs.exists("/thirdparty.teae") then
		fs.mount(dir..fs.getPathSeparator().."game/engine.teae", "/", true)
		fs.mount(dir..fs.getPathSeparator().."game/thirdparty.teae", "/", true)
		print("Using engine.teae")
	end
end

-- We need it no more, lets forget about it just it case some malovelant script tried something silly
__SELFEXE = nil
