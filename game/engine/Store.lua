require "engine.class"
local Entity = require "engine.Entity"
local Inventory = require "engine.interface.ActorInventory"
local ShowStore = require "engine.dialogs.ShowStore"
local GetQuantity = require "engine.dialogs.GetQuantity"

module(..., package.seeall, class.inherit(Entity, Inventory))

function _M:init(t, no_default)
	t = t or {}

	t.body = {INVEN=10000}

	Entity.init(self, t, no_default)
	Inventory.init(self, t, no_default)
end

--- Fill the store with goods
-- @param level the level to generate for (inctance of type engine.Level)
-- @param zone the zone to generate for
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
			if filter.id then e:identify(filter.id) end
			self:addObject(inven, e)
			print("[STORE] stocking up: ", e.name)
		end
	end
	self:sortInven(inven)
	self.last_filled = game.turn
end

--- Actor interacts with the store
-- @param who the actor who interracts
function _M:interact(who)
	local store, inven = self:getInven("INVEN"), who:getInven("INVEN")
	local d; d = ShowStore.new("Store: "..self.name, store, inven, nil, nil, function(what, o, item)
		if what == "buy" then
			if o:getNumber() > 1 then
				local q = GetQuantity.new(nil, nil, function(qty) self:doBuy(who, o, item, qty) print(d) d:updateStore() end)
				q.qty = o:getNumber()
				game:registerDialog(q)
			else
				self:doBuy(who, o, item, 1)
			end
		else
			if o:getNumber() > 1 then
				local q
				q = GetQuantity.new(nil, nil, function(qty) self:doSell(who, o, item, qty) d:updateStore() end)
				q.qty = o:getNumber()
				game:registerDialog(q)
			else
				self:doSell(who, o, item, 1)
			end
		end
	end, function(what, o)
		return self:descObject(who, what, o)
	end)
	game:registerDialog(d)
end

function _M:doBuy(who, o, item, nb)
	local max_nb = o:getNumber()
	nb = math.min(nb, max_nb)
	nb = self:onBuy(who, o, item, nb)
	if nb then
		local store, inven = self:getInven("INVEN"), who:getInven("INVEN")
		for i = 1, nb do
			local o = self:removeObject(store, item)
			who:addObject(inven, o)
		end
		self:sortInven(store)
		who:sortInven(inven)
		self.changed = true
		who.changed = true
	end
end

function _M:doSell(who, o, item, nb)
	local max_nb = o:getNumber()
	nb = math.min(nb, max_nb)
	nb = self:onSell(who, o, item, nb)
	if nb then
		local store, inven = self:getInven("INVEN"), who:getInven("INVEN")
		for i = 1, nb do
			local o = who:removeObject(inven, item)
			self:addObject(store, o)
		end
		self:sortInven(store)
		who:sortInven(inven)
		self.changed = true
		who.changed = true
	end
end

--- Called on object purchase
-- @param who the actor buying
-- @param o the object trying to be purchased
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to buy
-- @return a number (or nil) if allowed to buy, giving the number of objects to buy
function _M:onBuy(who, o, item, nb)
	return nb
end

--- Called on object sale
-- @param who the actor selling
-- @param o the object trying to be sold
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to sell
-- @return a number (or nil) if allowed to sell, giving the number of objects to sell
function _M:onSell(who, o, item, nb)
	return nb
end

--- Called to describe an object, being to sell or to buy
-- @param who the actor
-- @param what either "sell" or "buy"
-- @param o the object
-- @return a string (possibly multiline) describing the object
function _M:descObject(what, o)
	return o:getDesc()
end
