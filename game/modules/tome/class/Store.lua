require "engine.class"
local Entity = require "engine.Entity"
local Inventory = require "engine.interface.ActorInventory"

module(..., package.seeall, class.inherit(Entity, Inventory))

_M.stores_def = {}

function _M:init(t, no_default)
	t = t or {}

	t.body = {INVEN=10000}

	Entity.init(self, t, no_default)
	Inventory.init(self, t, no_default)
end

--- Fill the store with goods
function _M:loadup(level, zone)
	local s = self.store
	if not s then error("Store without a store field") end
	if self.last_filled and game.turn and self.last_filled >= game.turn - s.restock_after then
		print("[STORE] not restocking yet", game.turn, s.restock_after, self.last_filled)
		return
	end
	local inven = self:getInven("INVEN")

	for i = 1, rng.range(s.min_fill, s.max_fill) - #inven do
		local filter = rng.table(s.filters)
		local e = zone:makeEntity(level, "object", filter)
		if e then
			self:addObject(inven, e)
			print("[STORE] stocking up: ", e.name)
		end
	end
	self.last_filled = game.turn
end
