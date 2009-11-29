require "engine.class"
require "engine.Actor"
require "engine.interface.ActorLife"
require "engine.interface.ActorLevel"
require "engine.interface.ActorStats"
require "engine.interface.ActorTalents"
require "engine.interface.BloodyDeath"
require "mod.class.interface.Combat"

module(..., package.seeall, class.inherit(
	-- a ToME actor is a complex beast it uses may inetrfaces
	engine.Actor,
	engine.interface.ActorLife,
	engine.interface.ActorLevel,
	engine.interface.ActorStats,
	engine.interface.ActorTalents,
	engine.interface.BloodyDeath,
	mod.class.interface.Combat
))

function _M:init(t)
	engine.Actor.init(self, t)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorLevel.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorTalents.init(self, t)

	self.unused_stats = 0
	self.unused_talents = 0
	self.unused_talents_types = 0
end

function _M:move(x, y, force)
	local moved = false
	if force or self:enoughEnergy() then
		moved = engine.Actor.move(self, game.level.map, x, y, force)
		if not force and moved then self:useEnergy() end
	end
	return moved
end

function _M:teleportRandom(dist)
	local poss = {}

	for i = self.x - dist, self.x + dist do
		for j = self.y - dist, self.y + dist do
			if game.level.map:isBound(i, j) and
			   core.fov.distance(self.x, self.y, i, j) <= dist and
			   not game.level.map:checkAllEntities(i, j, "block_move") then
				poss[#poss+1] = {i,j}
			end
		end
	end

	local pos = poss[rng.range(1, #poss)]
	return self:move(pos[1], pos[2], true)
end

function _M:tooltip()
	return ("%s\n#00ffff#Level: %d\nExp: %d/%d\n#ff0000#HP: %d"):format(self.name, self.level, self.exp, self:getExpChart(self.level+1) or "---", self.life)
end

function _M:die(src)
	-- Gives the killer some exp for the kill
	if src then
		src:gainExp(self:worthExp())
	end
	-- Do we get a blooooooody death ?
	if rng.percent(33) then self:bloodyDeath() end
	return true
end

function _M:levelup()
	self.unused_stats = self.unused_stats + 3
	self.unused_talents = self.unused_talents + 1
end

--- Notifies a change of stat value
function _M:onStatChange(stat, v)
	if stat == self.STAT_CON then
		self.max_life = self.max_life + 5 * v
	elseif stat == self.STAT_MAG then
		self.max_mana = self.max_mana + 5 * v
	end
end

function _M:attack(target)
	self:bumpInto(target)
end

--- Tries to get a target from the user
function _M:getTarget()
	return self.target.x, self.target.y
end

--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab)
	return self:enoughEnergy()
end

--- Called before a talent is used
-- Check if it must use a turn, mana, stamina, ...
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(ab, ret)
	if ret == nil then return end
	if ab.message then
		game.logSeen(self, "%s", self:useTalentMessage(ab))
	elseif ab.type[1]:find("^spell/") then
		game.logSeen(self, "%s casts %s.", self.name:capitalize(), ab.name)
	else
		game.logSeen(self, "%s uses %s.", self.name:capitalize(), ab.name)
	end
	self:useEnergy()
	return true
end
