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
require "engine.Dialog"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Death!", 500, 300)

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 45) / self.font_h) - 1

	self:keyCommands(nil, {
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
	})
	self:mouseZones{
		{ x=2, y=45, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:learn(true)
			elseif button == "right" then self:learn(false)
			end
			self.changed = true
		end },
	}
end

--- Clean the actor from debuffs/buffs
function _M:cleanActor()
	local effs = {}

	-- Go through all spell effects
	for eff_id, p in pairs(self.actor.tmp) do
		local e = self.actor.tempeffect_def[eff_id]
		effs[#effs+1] = {"effect", eff_id}
	end

	-- Go through all sustained spells
	for tid, act in pairs(self.actor.sustain_talents) do
		if act then
			effs[#effs+1] = {"talent", tid}
		end
	end

	while #effs > 0 do
		local eff = rng.tableRemove(effs)

		if eff[1] == "effect" then
			self.actor:removeEffect(eff[2])
		else
			local old = self.actor.energy.value
			self.actor:useTalent(eff[2])
			-- Prevent using energy
			self.actor.energy.value = old
		end
	end
end

--- Restore ressources
function _M:restoreRessources()
	self.actor.life = self.actor.max_life
	self.actor.mana = self.actor.max_mana
	self.actor.stamina = self.actor.max_stamina
	self.actor.equilibrium = 0
	self.actor.air = self.actor.max_air

	self.actor.energy.value = game.energy_to_act
end

--- Basic resurection
function _M:resurrectBasic()
	self.actor.dead = false
	self.actor.died = (self.actor.died or 0) + 1

	local x, y = util.findFreeGrid(self.actor.x, self.actor.y, 20, true, {[Map.ACTOR]=true})
	if not x then x, y = self.actor.x, self.actor.y end
	self.actor.x, self.actor.y = nil, nil

	self.actor:move(x, y, true)
	game.level:addEntity(self.actor)
	game:unregisterDialog(self)
	game.level.map:redisplay()
end

function _M:use()
	if not self.list[self.sel] then return end
	local act = self.list[self.sel].action

	if act == "exit" then
		local save = Savefile.new(game.save_name)
		save:delete()
		save:close()
		util.showMainMenu()
	elseif act == "dump" then
	elseif act == "cheat" then
		game.logPlayer(self.actor, "#LIGHT_BLUE#You resurrect! CHEATER !")

		self:cleanActor()
		self:restoreRessources()
		self:resurrectBasic()
	elseif act == "blood_life" then
		self.actor.blood_life = false
		game.logPlayer(self.actor, "#LIGHT_RED#The Blood of Life rushes through your dead body. You come back to life!")

		self:cleanActor()
		self:restoreRessources()
		self:resurrectBasic()
	end
end

function _M:generateList()
	local list = {}

	if config.settings.tome.cheat then list[#list+1] = {name="Resurrect by cheating", action="cheat"} end
	if self.actor:attr("blood_life") and not self.actor:attr("undead") then list[#list+1] = {name="Resurrect with the Blood of Life", action="blood_life"} end

	list[#list+1] = {name="Character dump", action="dump"}
	list[#list+1] = {name="Exit to main menu", action="exit"}

	self.list = list
end

function _M:drawDialog(s)
	local help = ([[You have #LIGHT_RED#died##LAST#!
Death in T.o.M.E. is usually permanent, but if you have a means of resurrection it will be proposed in the menu below.
You can dump your character data to a file to remember her/him forever, or you can exit and try again to survive in the wilds!
]]):splitLines(self.iw - 10, self.font)

	local h = 2
	local r, g, b
	for i = 1, #help do
		r, g, b = s:drawColorString(self.font, help[i], 5, h, r, g, b)
		h = h + self.font:lineSkip()
	end
	h = h + self.font:lineSkip()

	self:drawWBorder(s, 2, h - 0.5 * self.font:lineSkip(), self.iw - 4)

	self:drawSelectionList(s, 2, h, self.font_h, self.list, self.sel, "name")
	self.changed = false
end
