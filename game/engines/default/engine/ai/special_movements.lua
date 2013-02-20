-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

-- Defines some special movement AIs

-- Ghoul AI: move, pause, move pause, ...
newAI("move_ghoul", function(self)
	if self.ai_target.actor then
		if not rng.percent(self.ai_state.pause_chance or 30) then
			local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
			return self:moveDirection(tx, ty)
		else
			self:useEnergy()
			return true
		end
	end
end)

-- Snake AI: move in the general direction but "slide" along
newAI("move_snake", function(self)
	if self.ai_target.actor then
		local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
		-- We we are in striking distance, strike!
		if self:isNear(tx, ty) then
			return self:moveDirection(tx, ty)
		else
			local rd = rng.range(1, 3)
			if rd == 1 then
				-- nothing, we move in the correct direction
			elseif rd == 2 then
				-- move to the left
				local dir = util.getDir(tx, ty, self.x, self.y)
				local nextDir = util.dirSides(dir, self.x, self.y)
				tx, ty = util.coordAddDir(self.x, self.y, nextDir and nextDir.left or dir)
			elseif rd == 3 then
				-- move to the right
				local dir = util.getDir(tx, ty, self.x, self.y)
				local nextDir = util.dirSides(dir, self.x, self.y)
				tx, ty = util.coordAddDir(self.x, self.y, nextDir and nextDir.right or dir)
			end
			return self:moveDirection(tx, ty)
		end
	end
end)
