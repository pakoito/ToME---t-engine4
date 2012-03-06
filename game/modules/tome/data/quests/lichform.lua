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

name = "From Death, Life"
stables = 0
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "The affairs of this mortal world are trifling compared to your true goal: To conquer death."
	desc[#desc+1] = "Your studies have uncovered much surrounding this subject, but now you must prepare for your glorious rebirth."
	desc[#desc+1] = "You will need:"

	if who.level >= 20 then desc[#desc+1] = "#LIGHT_GREEN#* You are experienced enough.#WHITE#"
	else desc[#desc+1] = "#SLATE#* The ceremony will require that you are worthy, experienced, and possessed of a certain amount of power#WHITE#" end

	if self:isCompleted("heart") then desc[#desc+1] = "#LIGHT_GREEN#* You have 'extracted' the heart of one of your fellow necromancers.#WHITE#"
	else desc[#desc+1] = "#SLATE#* The beating heart of a powerful necromancer.#WHITE#" end

	if who:isQuestStatus("shertul-fortress", self.COMPLETED, "butler") then
		desc[#desc+1] = "#LIGHT_GREEN#* Yiilkgur the Sher'tul Fortress is a suitable location.#WHITE#"

		if who:hasQuest("shertul-fortress").shertul_energy >= 40 then
			desc[#desc+1] = "#LIGHT_GREEN#* Yiilkgur has enough energy.#WHITE#"

			if who:knowTalent(who.T_LICHFORM) then desc[#desc+1] = "#LIGHT_GREEN#* You are now on the path of lichdom.#WHITE#"
			else desc[#desc+1] = "#SLATE#* Use the control orb of Yiilkgur to begin the ceremony.#WHITE#" end
		else desc[#desc+1] = "#SLATE#* Your lair must amass enough energy to use in your rebirth (40 energy).#WHITE#" end
	else
		desc[#desc+1] = "#SLATE#* The ceremony will require a suitable location, secluded and given to the channelling of energy#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:learnTalent(who.T_LICHFORM, true, 1, {no_unlearn=true})
		require("engine.ui.Dialog"):simplePopup("Lichform", "The secrets of death lay open to you! The skill 'Lichform' has been unlocked!")
	end
end

check_lichform = function(self, who)
	if self:isStatus(self.DONE) then return end
	if who.level < 20 then return end
	if not self:isCompleted("heart") then return end
	local q = who:hasQuest("shertul-fortress")
	if not q then return end
	if not q:isCompleted("butler") then return end
	if q.shertul_energy < 40 then return end
	if not who:knowTalentType("spell/necrosis") then return end

	return true
end
