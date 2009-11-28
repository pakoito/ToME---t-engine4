require "engine.class"
require "engine.Actor"
require "engine.interface.ActorLife"
require "engine.interface.ActorLevel"
require "engine.interface.ActorStats"
require "engine.interface.ActorAbilities"
require "engine.interface.BloodyDeath"
require "mod.class.interface.Combat"

module(..., package.seeall, class.inherit(
	-- a ToME actor is a complex beast it uses may inetrfaces
	engine.Actor,
	engine.interface.ActorLife,
	engine.interface.ActorLevel,
	engine.interface.ActorStats,
	engine.interface.ActorAbilities,
	engine.interface.BloodyDeath,
	mod.class.interface.Combat
))

function _M:init(t)
	engine.Actor.init(self, t)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorLevel.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorAbilities.init(self, t)
end

function _M:move(x, y, force)
	local moved = false
	if force or self:enoughEnergy() then
		moved = engine.Actor.move(self, game.level.map, x, y, force)
		if not force and moved then self:useEnergy() end
	end
	return moved
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
end

function _M:levelup()

end

function _M:attack(target)
	self:bumpInto(target)
end

--- Tries to get a target from the user
function _M:getTarget()
	return self.target.x, self.target.y
end

--- Called before an ability is used
-- Check the actor can cast it
-- @param ab the ability (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseAbility(ab)
	return self:enoughEnergy()
end

--- Called before an ability is used
-- Check if it must use a turn, mana, stamina, ...
-- @param ab the ability (not the id, the table)
-- @param ret the return of the ability action
-- @return true to continue, false to stop
function _M:postUseAbility(ab, ret)
	if ret == nil then return end
	self:useEnergy()
	return true
end
