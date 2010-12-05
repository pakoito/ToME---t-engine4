-- ToME - Tales of Maj'Eyal
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
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Death!", 500, 300)

	actor:saveUUID()

	self:generateList()

	self.c_desc = Textzone.new{width=self.iw, auto_height=true, text=[[You have #LIGHT_RED#died#LAST#!
Death in T.o.M.E. is usually permanent, but if you have a means of resurrection it will be proposed in the menu below.
You can dump your character data to a file to remember her/him forever, or you can exit and try once again to survive in the wilds!
]]}
	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_desc},
		{left=5, top=self.c_desc.h, padding_h=10, ui=Separator.new{dir="vertical", size=self.iw - 10}},
		{left=0, bottom=0, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)
end

--- Clean the actor from debuffs/buffs
function _M:cleanActor(actor)
	local effs = {}

	-- Go through all spell effects
	for eff_id, p in pairs(actor.tmp) do
		local e = actor.tempeffect_def[eff_id]
		effs[#effs+1] = {"effect", eff_id}
	end

	-- Go through all sustained spells
	for tid, act in pairs(actor.sustain_talents) do
		if act then
			effs[#effs+1] = {"talent", tid}
		end
	end

	while #effs > 0 do
		local eff = rng.tableRemove(effs)

		if eff[1] == "effect" then
			actor:removeEffect(eff[2])
		else
			actor:forceUseTalent(eff[2], {ignore_energy=true})
		end
	end
end

--- Restore ressources
function _M:restoreRessources(actor)
	actor:resetToFull()

	actor.energy.value = game.energy_to_act
end

--- Basic resurection
function _M:resurrectBasic(actor)
	actor.dead = false
	actor.died = (actor.died or 0) + 1

	local x, y = util.findFreeGrid(actor.x, actor.y, 20, true, {[Map.ACTOR]=true})
	if not x then x, y = actor.x, actor.y end
	actor.x, actor.y = nil, nil

	actor:move(x, y, true)
	game.level:addEntity(actor)
	game:unregisterDialog(self)
	game.level.map:redisplay()
	actor.changed = true

	world:gainAchievement("UNSTOPPABLE", actor)
end

function _M:use(item)
	if not item then return end
	local act = item.action

	if act == "exit" then
		local save = Savefile.new(game.save_name)
		save:delete()
		save:close()
		world:saveWorld()
		if item.subaction == "none" then
			util.showMainMenu()
		elseif item.subaction == "restart" then
			util.showMainMenu(false, engine.version[4], engine.version[1].."."..engine.version[2].."."..engine.version[3], game.__mod_info.short_name, game.save_name, true, "auto_quickbirth=true")
		end
	elseif act == "dump" then
		game:registerDialog(require("mod.dialogs.CharacterSheet").new(self.actor))
	elseif act == "cheat" then
		game.logPlayer(self.actor, "#LIGHT_BLUE#You resurrect! CHEATER !")

		self:cleanActor(self.actor)
		self:restoreRessources(self.actor)
		self:resurrectBasic(self.actor)
	elseif act == "blood_life" then
		self.actor.blood_life = false
		game.logPlayer(self.actor, "#LIGHT_RED#The Blood of Life rushes through your dead body. You come back to life!")

		self:cleanActor(self.actor)
		self:restoreRessources(self.actor)
		self:resurrectBasic(self.actor)
	elseif act == "easy_mode" then
		self.actor:attr("easy_mode_lifes", -1)
		game.logPlayer(self.actor, "#LIGHT_RED#You resurrect!")

		self.actor.x = self.actor.entered_level.x
		self.actor.y = self.actor.entered_level.y
		self:cleanActor(self.actor)
		self:resurrectBasic(self.actor)

		for uid, e in pairs(game.level.entities) do
			self:restoreRessources(e)
		end
	elseif act == "skeleton" then
		self.actor:attr("re-assembled", 1)
		game.logPlayer(self.actor, "#YELLOW#Your bones magically come back together. You are once more able to dish out pain to your foes!")

		self:cleanActor(self.actor)
		self:restoreRessources(self.actor)
		self:resurrectBasic(self.actor)
	elseif act:find("^consume") then
		local inven, item, o = item.inven, item.item, item.object
		self.actor:removeObject(inven, item)
		game.logPlayer(self.actor, "#YELLOW#Your %s is consumed and disappears! You come back to life!", o:getName{do_colour=true})

		self:cleanActor(self.actor)
		self:restoreRessources(self.actor)
		self:resurrectBasic(self.actor)
	end
end

function _M:generateList()
	local list = {}

	if config.settings.tome and config.settings.tome.cheat then list[#list+1] = {name="Resurrect by cheating", action="cheat"} end
	if self.actor:attr("easy_mode_lifes") then list[#list+1] = {name=("Resurrect with easy mode (%d left)"):format(self.actor.easy_mode_lifes), action="easy_mode"} end
	if self.actor:attr("blood_life") and not self.actor:attr("undead") then list[#list+1] = {name="Resurrect with the Blood of Life", action="blood_life"} end
	if self.actor:getTalentLevelRaw(self.actor.T_SKELETON_REASSEMBLE) >= 5 and not self.actor:attr("re-assembled") then list[#list+1] = {name="Re-assemble your bones and resurrect (Skeleton ability)", action="skeleton"} end

	local consumenb = 1
	self.actor:inventoryApplyAll(function(inven, item, o)
		if o.one_shot_life_saving and (not o.slot or inven.worn) then
			list[#list+1] = {name="Resurrect by consuming "..o:getName{do_colour=true}, action="consume"..consumenb, inven=inven, item=item, object=o}
			consumenb = consumenb + 1
		end
	end)

	list[#list+1] = {name="Character dump", action="dump"}
	list[#list+1] = {name="Restart the same character", action="exit", subaction="restart"}
	list[#list+1] = {name="Exit to main menu", action="exit", subaction="none"}

	self.list = list
end
