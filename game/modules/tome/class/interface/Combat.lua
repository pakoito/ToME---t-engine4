require "engine.class"

--- Interface to add ToME combat system
module(..., package.seeall, class.make)

--- Makes the bloody death happen
--[[
The ToME combat system has the following attributes:
- attack power: increases chances to hit against high defence
- defence: increases chances to miss against high attack power
- armor: direct reduction of damage done
- armor penetration: reduction of target's armor
- damage: raw damage done
]]
function _M:attackTarget(target)
	local sc = self.combat
	local tc = target.combat

	if not sc then sc = {dam=0, atk=0, apr=0, def=0, armor=0} end
	if not tc then tc = {dam=0, atk=0, apr=0, def=0, armor=0} end

	-- Does the blow connect?
	local hit = rng.avg(sc.atk * 2 / 3, sc.atk) - tc.def
	-- If hit is over 0 it connects, if it is 0 we still have 50% chance
	if hit > 0 or (hit == 0 and rng.percent(50)) then
		local dam = rng.avg(sc.dam * 2 / 3, sc.dam) - math.max(0, tc.armor - sc.apr)
		game.logSeen(target, "%s hits %s for #aaaaaa#%0.2f physical damage#ffffff#.", self.name:capitalize(), target.name, dam)
		target:takeHit(dam, self)
	else
		game.logSeen(target, "%s misses %s.", self.name:capitalize(), target.name)
	end
end
