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

name = "An apprentice task"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You met a novice mage who was tasked to collect many staves."
	desc[#desc+1] = "He asked for your help should you collect some that you do not use."
	if self:isCompleted() then
	else
		desc[#desc+1] = "#SLATE#* "..self.nb_collect.."/15#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.nb_collect = 0
end

collect_staff = function(self, who, dialog)
	who:showEquipInven("Offer which staff?",
		function(o) return o.type == "weapon" and o.subtype == "staff" end,
		function(o, inven, item)
			self.nb_collect = self.nb_collect + 1
			if self.nb_collect >= 15 then who:setQuestStatus(self, self.COMPLETED) end
			who:removeObject(who:getInven(inven), item)
			game.log("You have no more %s", o:getName{no_count=true, do_color=true})
			who:sortInven(who:getInven(inven))
			dialog:regen()
			return true
		end
	)
end

can_offer = function(self, who)
	if self.nb_collect >= 15 then return end

	for inven_id, inven in pairs(who.inven) do
		for item, o in ipairs(inven) do
			if o.type == "weapon" and o.subtype == "staff" then return true end
		end
	end
end

access_angolwen = function(self, player)
	local g = mod.class.Grid.new{
		show_tooltip=true,
		name="Angolwen, the hidden city of magic",
		desc="Secret place of magic, set apart from the world to protect it.",
		display='*', color=colors.WHITE, image="terrain/town1.png",
		notice = true,
		change_level=1, change_zone="town-angolwen"
	}
	local p = mod.class.Grid.new{
		show_tooltip=true,
		name="Portal to Angolwen",
		desc="The city of magic lies inside the mountains to the west, either a spell or a portal is needed to access it.",
		display='*', color=colors.VIOLET, image="terrain/grass_teleport.png",
		notice = true,
		change_level=1, change_zone="town-angolwen"
	}
	g:resolve() g:resolve(nil, true)
	p:resolve() p:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", 14, 27)
	game.zone:addEntity(game.level, p, "terrain", 16, 27)

	game:setAllowedBuild("mage", true)
	world:gainAchievement("THE_SECRET_CITY", player)
end

ring_gift = function(self, player)
	local o = game.zone:makeEntity(game.level, "object", {type="jewelry", subtype="ring", force_ego={"RING_ARCANE_POWER","RING_BURNING","RING_FREEZING","RING_SHOCK","RING_MAGIC"}}, player.level + 3)
	if o then
		o:identify(true)
		player:addObject(player.INVEN_INVEN, o)
		game.zone:addEntity(game.level, o, "object")
		game.logPlayer(player, "You receive: %s", o:getName{do_color=true})
	end
end
