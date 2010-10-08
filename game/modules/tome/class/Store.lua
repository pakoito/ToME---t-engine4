-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
local Store = require "engine.Store"
local Dialog = require "engine.Dialog"

module(..., package.seeall, class.inherit(Store))

_M.stores_def = {}

function _M:loadStores(f)
	self.stores_def = self:loadList(f)
end

function _M:init(t, no_default)
	t.buy_percent = t.buy_percent or 10
	t.sell_percent = t.sell_percent or 100
	Store.init(self, t, no_default)

	if self.store and self.store.restock_after then self.store.restock_after = self.store.restock_after * 10 end
end

--- Called on object purchase try
-- @param who the actor buying
-- @param o the object trying to be purchased
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to buy
-- @return true if allowed to buy
function _M:tryBuy(who, o, item, nb)
	local price = o:getPrice() * self.sell_percent / 100
	if who.money >= price * nb then
		return nb
	else
		Dialog:simplePopup("Not enough gold", "You do not have enough gold!")
	end
end

--- Called on object sale try
-- @param who the actor selling
-- @param o the object trying to be sold
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to sell
-- @return true if allowed to sell
function _M:trySell(who, o, item, nb)
	local price = o:getPrice() * self.buy_percent / 100
	if price <= 0 or nb <= 0 then return end
	return nb
end

--- Called on object purchase
-- @param who the actor buying
-- @param o the object trying to be purchased
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to buy
-- @param before true if this happens before removing the item
-- @return true if allowed to buy
function _M:onBuy(who, o, item, nb, before)
	if before then return end
	local price = o:getPrice() * self.sell_percent / 100
	if who.money >= price * nb then
		who:incMoney(- price * nb)
	end
end

--- Called on object sale
-- @param who the actor selling
-- @param o the object trying to be sold
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to sell
-- @param before true if this happens before removing the item
-- @return true if allowed to sell
function _M:onSell(who, o, item, nb, before)
	if before then o:identify(true) return end

	local price = o:getPrice() * self.buy_percent / 100
	if price <= 0 or nb <= 0 then return end
	who:incMoney(price * nb)
end

--- Called to describe an object, being to sell or to buy
-- @param who the actor
-- @param what either "sell" or "buy"
-- @param o the object
-- @return a string (possibly multiline) describing the object
function _M:descObject(who, what, o)
	if what == "buy" then
		local desc = ("Buy for: %0.2f gold (You have %0.2f gold)\n\n"):format(o:getPrice() * self.sell_percent / 100, who.money)
		desc = desc .. o:getDesc()
		return desc
	else
		local desc = ("Sell for: %0.2f gold (You have %0.2f gold)\n\n"):format(o:getPrice() * self.buy_percent / 100, who.money)
		desc = desc .. o:getDesc()
		return desc
	end
end

--- Called to describe an object's price, being to sell or to buy
-- @param who the actor
-- @param what either "sell" or "buy"
-- @param o the object
-- @return a string describing the price
function _M:descObjectPrice(who, what, o)
	if what == "buy" then
		return o:getPrice() * self.sell_percent / 100, who.money
	else
		return o:getPrice() * self.buy_percent / 100, who.money
	end
end

--- Actor interacts with the store
-- @param who the actor who interracts
function _M:interact(who)
	who:sortInven()
	Store.interact(self, who)
end
