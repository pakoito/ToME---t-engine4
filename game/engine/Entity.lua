--- A game entity
-- An entity is anything that goes on a map, terrain features, objects, monsters, player, ...
-- Usually there is no need to use it directly, and it is betetr to use specific engine.Grid, engine.Actor or engine.Object
-- classes. Most modules will want to subclass those anyway to add new comportments
module(..., package.seeall, class.make)

local next_uid = 1

-- Setup the uids repository as a weak value table, when the entities are no more used anywhere else they disappear from there too
setmetatable(__uids, {__mode="v"})

--- Initialize an entity
-- Any subclass MUST call this constructor
-- @param t a table defining the basic properties of the entity
-- @usage Entity.new{display='#', color_r=255, color_g=255, color_b=255}
function _M:init(t)
	t = t or {}
	self.uid = next_uid
--	__uids[self.uid] = self

	for k, e in pairs(t) do self[k] = e end

	self.image = self.image or nil
	self.display = self.display or '.'
	self.color_r = self.color_r or 0
	self.color_g = self.color_g or 0
	self.color_b = self.color_b or 0
	self.color_br = self.color_br or -1
	self.color_bg = self.color_bg or -1
	self.color_bb = self.color_bb or -1
	self.block_sight = self.block_sight or false
	self.block_move = self.block_move or false

	next_uid = next_uid + 1
end

-- If we are cloned we need a new uid
function _M:cloned()
	self.uid = next_uid
--	__uids[self.uid] = self
	next_uid = next_uid + 1
end

--- Check for an entity's property
-- If not a function it returns it directly, otherwise it calls the function
-- with the extra parameters
-- @param prop the property name to check
function _M:check(prop, ...)
	if type(self[prop]) == "function" then return self[prop](self, ...)
	else return self[prop]
	end
end

--- Loads a list of entities from a definition file
-- @param ... the files to load from
-- @usage MyEntityClass:loadList("/data/my_entities_def.lua")
function _M:loadList(...)
	local res = {}

	for i, file in ipairs{...} do
		local f, err = loadfile(file)
		if err then error(err) end
		local data = f()
		for i, a in ipairs(data) do
			local e = self.new(a)
			res[#res+1] = e
			if a.define_as then res[a.define_as] = e end
		end
	end
	return res
end
