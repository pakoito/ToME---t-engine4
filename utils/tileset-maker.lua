--- This is a really naive algorithm, it will not handle objects and such.
-- Use only for small tables
function table.serialize(src, sub, no_G)
	local str = ""
	if sub then str = "{" end
	for k, e in pairs(src) do
		local nk, ne = k, e
		local tk, te = type(k), type(e)

		if no_G then
			if tk == "table" then nk = "["..table.serialize(nk, true).."]"
			elseif tk == "string" then -- nothing
			else nk = "["..nk.."]"
			end
		else
			if tk == "table" then nk = "["..table.serialize(nk, true).."]"
			elseif tk == "string" then nk = string.format("[%q]", nk)
			else nk = "["..nk.."]"
			end
			if not sub then nk = "_G"..nk end
		end

		if te == "table" then
			str = str..string.format("%s=%s ", nk, table.serialize(ne, true))
		elseif te == "number" then
			str = str..string.format("%s=%f ", nk, ne)
		elseif te == "string" then
			str = str..string.format("%s=%q ", nk, ne)
		elseif te == "boolean" then
			str = str..string.format("%s=%s ", nk, tostring(ne))
		end
		if sub then str = str..", " end
	end
	if sub then str = str.."}" end
	return str
end


local gd = require "gd"


function makeSet(w, h)
	local used = {}
	local im = gd.createTrueColor(w, h)
	im:alphaBlending(false)
	im:saveAlpha(true)
	im:filledRectangle(0, 0, w, h, im:colorAllocateAlpha(0, 0, 0, 127))

	for i = 0, 512, 64 do
		used[i] = {}
		for j = 0, 512, 64 do
			used[i][j] = false
		end
	end

	return im, used
end

local w, h = 512, 512
local id = 1

local pos = {}

local list = {...}
local basename = table.remove(list, 1)
local prefix = table.remove(list, 1)

function fillSet(rlist)
	local im, used = makeSet(w, h)
	local i, j = 0, 0
	while #rlist > 0 do
		local d = table.remove(rlist)
		print("SRC", d.file, d.mw, d.mh)

		if i + d.mw > w then
			i = 0 j = j + d.mh
		end
		if j + d.mh > h then
			im:png(basename..id..".png")
			im, used = makeSet(w, h)
			i, j = 0, 0
			id = id + 1
		end

		im:copyResampled(d.src, i, j, 0, 0, d.mw, d.mh, d.mw, d.mh)
		pos[prefix..d.file] = {x=i/w, y=j/h, factorx=d.mw/w, factory=d.mh/h, w=d.mw, h=d.mh, set=prefix..basename..id..".png"}

		used[i][j] = true
		if d.mw > 64 then used[i+64][j] = true end
		if d.mh > 64 then used[i][j+64] = true end
		if d.mw > 64 and d.mh > 64 then used[i+64][j+64] = true end

		i = i + d.mw
	end
	im:png(basename..id..".png")
end

-----------------------------------------------------------------------
-- 64x64
-----------------------------------------------------------------------
local rlist = {}
for _, file in ipairs(list) do
	if file:sub(1, 2) == "./" then file = file:sub(3) end

	local src = gd.createFromPng(file)
	local mw, mh = src:sizeXY()
	if mw == 64 and mh == 64 then rlist[#rlist+1] = {file=file, src=src, mw=mw, mh=mh} end
end
table.sort(rlist, function(a,b)
	local ai, bi = a.mw + a.mh, b.mw + b.mh
	if ai == bi then return a.file < b.file end
	return ai < bi
end)

fillSet(rlist)

-----------------------------------------------------------------------
-- 64x128
-----------------------------------------------------------------------
local rlist = {}
for _, file in ipairs(list) do
	if file:sub(1, 2) == "./" then file = file:sub(3) end

	local src = gd.createFromPng(file)
	local mw, mh = src:sizeXY()
	if mw == 64 and mh == 128 then rlist[#rlist+1] = {file=file, src=src, mw=mw, mh=mh} end
end
table.sort(rlist, function(a,b)
	local ai, bi = a.mw + a.mh, b.mw + b.mh
	if ai == bi then return a.file < b.file end
	return ai < bi
end)

fillSet(rlist)

local f = io.open(basename..".lua", "w")
f:write(table.serialize(pos))
f:close()

