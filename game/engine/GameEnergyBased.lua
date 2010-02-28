require "engine.class"
require "engine.Game"

--- A game type that gives each entities energy
-- When an entity reaches an energy level it is allowed to act (it calls the entity"s "act" method)
-- @inherit engine.Game
module(..., package.seeall, class.inherit(engine.Game))

--- Setup the game
-- @param keyhandler the default keyhandler for this game
-- @energy_to_act how much energy does an entity need to act
-- @energy_per_tick how much energy does an entity recieves per game tick. This is multiplied by the entity energy.mod property
function _M:init(keyhandler, energy_to_act, energy_per_tick)
	self.energy_to_act, self.energy_per_tick = energy_to_act or 1000, energy_per_tick or 100
	engine.Game.init(self, keyhandler)

	self.entities = {}
	self:loaded()
end

function _M:loaded()
	engine.Game.loaded(self)

	-- Loading the game has defined new uids for entities, yet we hard referenced the old ones
	-- So we fix it
	local nes = {}
	for uid, e in pairs(self.entities) do
		nes[e.uid] = e
	end
	self.entities = nes

	-- Setup the entities repository as a weak value table, when the entities are no more used anywhere else they disappear from there too
	setmetatable(self.entities, {__mode="v"})
end

--- Gives energy and act if needed
function _M:tick()
	engine.Game.tick(self)

	-- Give some energy to entities
	if self.level then
		local i, e
		local arr = self.level.e_array
		for i = 1, #arr do
			e = arr[i]
			if e and e.act and e.energy then
				if e.energy.value < self.energy_to_act then
					e.energy.value = (e.energy.value or 0) + self.energy_per_tick * (e.energy.mod or 1)
				end
				if e.energy.value >= self.energy_to_act then
					e.energy.used = false
					e:act(self)
				end
			end
		end
	end

	local arr = self.entities
	for i, e in pairs(arr) do
		e = arr[i]
		if e and e.act and e.energy then
			if e.energy.value < self.energy_to_act then
				e.energy.value = (e.energy.value or 0) + self.energy_per_tick * (e.energy.mod or 1)
			end
			if e.energy.value >= self.energy_to_act then
				e.energy.used = false
				e:act(self)
			end
		end
	end
end

--- Adds an entity to the game
-- This differs from Level:addEntity in that it's not specific to actors and the entities are not bound to
-- the current level. Also they are stored in a *WEAK* table, so this wont hold them from garbage
-- collecting if they are not
function _M:addEntity(e)
	if not e.canAct or not e:canAct() then return end
	if self.entities[e.uid] and self.entities[e.uid] ~= e then error("Entity "..e.uid.." already present in the game and not the same") end
	self.entities[e.uid] = e
end

--- Removes an entity from the game
function _M:removeEntity(e)
	if not e.canAct or not e:canAct() then return end
	if not self.entities[e.uid] then error("Entity "..e.uid.." not present in the game") end
	self.entities[e.uid] = nil
end
