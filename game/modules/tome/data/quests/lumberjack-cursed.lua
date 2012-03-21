-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

name = "The beast within"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "You met a half-mad lumberjack fleeing a small village, rambling about an untold horror lurking there, slaughtering people."
	if self.lumberjacks_died > 0 then
		desc[#desc+1] = self.lumberjacks_died.." lumberjacks have died."
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	local g = mod.class.Grid.new{
		show_tooltip=true, always_remember = true,
		name="Small lumberjack village",
		display='*', color=colors.WHITE,
		notice = true, image="terrain/grass.png", add_mos={{image="terrain/town1.png"}},
		change_level=1, glow=true, change_zone="town-lumberjack-village",
	}
	g:resolve() g:resolve(nil, true)
	local level = game.level
	local spot = level:pickSpot{type="zone-pop", subtype="lumberjack-town"}
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)

	game.logPlayer(game.player, "He points in the direction of the Riljek forest to the north.")

	self.lumberjacks_died = 0
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		local money = math.max(0, (20 - self.lumberjacks_died) * 1.2)
		if money > 0 then
			who:incMoney(money)
			require("engine.ui.Dialog"):simplePopup("Thanks", ("The remaining lumberjacks collect some gold to thanks you (%0.2f)."):format(money))
		end
		if self.lumberjacks_died < 7 then
			local o = game.zone:makeEntity(game.level, "object", {type="tool", subtype="digger", tome_drops="boss"}, nil, true)
			if o then
				game:addEntity(game.level, o, "object")
				o:identify(true)
				who:addObject(who.INVEN_INVEN, o)
				require("engine.ui.Dialog"):simplePopup("Thanks", ("You saved most of us, please take this has a reward. (They give you %s)"):format(o:getName{do_color=true}))
			end
		end
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game:setAllowedBuild("afflicted")
		game:setAllowedBuild("afflicted_cursed", true)
		world:gainAchievement("CURSE_ERASER", game.player)
	end
end

lumberjack_dead = function(self)
	self.lumberjacks_died = self.lumberjacks_died + 1
	game.logSeen(game.player, "#LIGHT_RED#A lumberjack falls to the ground, dead.")
end
