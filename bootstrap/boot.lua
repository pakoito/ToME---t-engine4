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
	else
		dir = dir:gsub("(.*"..fs.getPathSeparator()..").+", "%1")..fs.getPathSeparator().."Resources"..fs.getPathSeparator()
	end

	print("SelfExe gave us app directory of:", dir)
	fs.mount(dir..fs.getPathSeparator().."game"..fs.getPathSeparator().."thirdparty", "/", true)
	fs.mount(dir..fs.getPathSeparator().."game", "/", true)
else
	print("No SelfExe, using basic path")
	fs.mount("game"..fs.getPathSeparator().."thirdparty", "/", true)
	fs.mount("game", "/", true)
end

-- Look for a core
function get_core(coretype, id)
	coretype = coretype or "te4core"

	local homepath = fs.getUserPath()..fs.getPathSeparator()..fs.getHomePath()..fs.getPathSeparator().."4.0"
	fs.mount(homepath, "/", 1)

	-- Look for possible cores - if id is -1 then check all the ones matching the given type and use the newest one
	local usable = {}
	for i, file in ipairs(fs.list("/engines/cores/")) do
		if file:find("%.tec$") then
			print("Looking for cores", coretype, id, " <=> ", file)
			if id > 0 and file == coretype.."-"..id..".tec" then
				usable[#usable+1] = {file=file, id=id}
				print("Possible engine core", file)
			elseif id == -1 and file:find(coretype) then
				local _, _, cid = file:find("%-([0-9]+)%.tec$")
				cid = tonumber(cid)
				if cid then
					usable[#usable+1] = {file=file, id=cid}
					print("Possible engine core", file)
				end
			end
		end
	end
	-- Order the cores to find the newest
	table.sort(usable, function(a, b) return b.id < a.id end)
	for i, file in ipairs(usable) do print("Selected cores:", file.id, file.file) end

	-- Check for sanity and tell the runner to use it
	local core = "/engines/cores/"..usable[1].file
	if fs.exists(core) then
		local rcore = fs.getRealPath(core)
		print("Using TE4CORE: ", core, rcore)
		fs.umount(homepath)
		return rcore
	end
	fs.umount(homepath)
	return "NO CORE"
end

-- We need it no more, lets forget about it just it case some malovelant script tried something silly
__SELFEXE = nil
