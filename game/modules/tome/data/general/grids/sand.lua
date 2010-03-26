newEntity{
	define_as = "SAND",
	name = "sand", image = "terrain/sand.png",
	display = '.', color={r=203,g=189,b=72},
}

newEntity{
	define_as = "SANDWALL",
	name = "sandwall", image = "terrain/sandwall.png",
	display = '#', color={r=203,g=189,b=72},
	always_remember = true,
	block_move = true,
	block_sight = true,
	air_level = -10,
	-- Dig only makes unstable tunnels
	dig = function(src, x, y, old)
		local sand = require("engine.Object").new{
			name = "unstable sand tunnel", image = "terrain/sand.png",
			display = '.', color={r=203,g=189,b=72},
			canAct = false,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.logSeen(self, "The unstable sand tunnel collapses!")

					local a = game.level.map(self.x, self.y, engine.Map.ACTOR)
					if a then
						game.logPlayer(a, "You are crushed by the collapsing tunnel! You suffocate!")
						a:suffocate(30, self)
						engine.DamageType:get(engine.DamageType.PHYSICAL).projector(self, self.x, self.y, engine.DamageType.PHYSICAL, a.life / 2)
					end
				end
			end
		}
		sand.summoner_gain_exp = true
		sand.summoner = src
		sand.old_feat = old
		sand.temporary = 20
		sand.x = x
		sand.y = y
		game.level:addEntity(sand)
		return nil, sand, true
	end,
}
