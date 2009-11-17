local mod_def = loadfile("/tome/init.lua")
if mod_def then
	local mod = {}
	setfenv(mod_def, mod)
	mod_def()

	if not mod.name or not mod.short_name or not mod.version or not mod.starter then os.exit() end
	require(mod.starter)
else
	os.exit()
end
