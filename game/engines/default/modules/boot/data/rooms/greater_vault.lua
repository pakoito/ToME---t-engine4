-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local max_w, max_h = 50, 50
local list = {
	"double-t", "crypt", "treasure1", "diggers", "hillbert_curve", "quiet", "lightning-vault", "water-vault",
}

return function(gen, id, lev, old_lev)
	local vaultid = rng.table(gen.data.greater_vaults_list or list)
	local vault_map = engine.Map.new(max_w, max_h)
	local Static = require("engine.generator.map.Static")
	local data = table.clone(gen.data)
	data.map = "vaults/"..vaultid

	local old_map = gen.level.map
	local old_game_level = game.level
	game.level = gen.level
	gen.level.map = vault_map
	local vault = Static.new(gen.zone, vault_map, gen.level, data)
	vault:generate(lev, old_lev)
	game.level = old_game_level
	gen.level.map = old_map

	local w = vault_map.w
	local h = vault_map.h
	return { name="greater_vault-"..vaultid.."-"..w.."x"..h, w=w, h=h, generator = function(self, x, y, is_lit)
		gen.map:import(vault_map, x, y)
		-- Make it a room, and make it special so that we do not tunnel through
		for i = x, x + w - 1 do for j = y, y + h - 1 do
			gen.map.room_map[i][j].special = true
			gen.map.room_map[i][j].room = id
			gen.map.attrs(i, j, "no_decay", true)
		end end
		if vault.gen_map.startx and vault.gen_map.starty then
			gen.spots[#gen.spots+1] = {x=vault.gen_map.startx + x, y=vault.gen_map.starty + y, check_connectivity="entrance", type="vault", subtype="greater"}
			return vault.gen_map.startx + x, vault.gen_map.starty + y
		end
	end}
end
