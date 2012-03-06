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

name = "The Arena"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Seeking wealth, glory, and a great fight, you challenge the Arena!"
	desc[#desc+1] = "Can you defeat your foes and become Master of Arena?"
	return table.concat(desc, "\n")
end

function win(self)
	game:playAndStopMusic("Lords of the Sky.ogg")

	game.player.winner = "arena"
	game:registerDialog(require("engine.dialogs.ShowText").new("Winner", "win", {playername=game.player.name, how="arena"}, game.w * 0.6))
end

function onWin(self, who)
	local desc = {}

	desc[#desc+1] = "#GOLD#Well done! You have won the Arena: Challenge of the Master#WHITE#"
	desc[#desc+1] = ""
	desc[#desc+1] = "You valiantly fought every creature the arena could throw at you and you emerged victorious!"
	desc[#desc+1] = "Glory to you, you are now the new master and your future characters will challenge you."
	return 0, desc
end
