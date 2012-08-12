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

local DamageType = require "engine.DamageType"

local print = function() end

-- Internal functions
local checkLOS = function(sx, sy, tx, ty)
	what = what or "block_sight"
	local l = core.fov.line(sx, sy, tx, ty, what)
	local lx, ly, is_corner_blocked = l:step()
	while lx and ly and not is_corner_blocked do
		if game.level.map:checkAllEntities(lx, ly, what) then break end

		lx, ly, is_corner_blocked = l:step()
	end
	-- Ok if we are at the end reset lx and ly for the next code
	if not lx and not ly and not is_corner_blocked then lx, ly = x, y end

	if lx == x and ly == y then return true, lx, ly end
	return false, lx, ly
end

local canFleeDmapKeepLos = function(self)
	if self.never_move then return false end -- Dont move, dont flee
	if self.ai_target.actor then
		local act = self.ai_target.actor
		local c = act:distanceMap(self.x, self.y)
		if not c then return end
		local dir
		for _, i in ipairs(util.adjacentDirs()) do
			local sx, sy = util.coordAddDir(self.x, self.y, i)
			-- Check LOS first
			if checkLOS(sx, sy, act.x, act.y) then
				local cd = act:distanceMap(sx, sy)
	--			print("looking for dmap", dir, i, "::", c, cd)
				if not cd or (c and (cd < c and self:canMove(sx, sy))) then c = cd; dir = i end
			end
		end
		if dir then
			local dx, dy = util.dirToCoord(dir, self.x, self.y)
			return true, self.x + dx, self.y + dy
		else
			return false
		end
	end
end

newAI("use_tactical", function(self)
	-- Find available talents
	print("============================== TACTICAL AI", self.name)
	local avail = {}
	local ok = false
	local target_dist = self.ai_target.actor and core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)
	local hate = self.ai_target.actor and (self:reactionToward(self.ai_target.actor) < 0)
	local has_los = self.ai_target.actor and self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y)
	local self_compassion = (self.ai_state.self_compassion == false and 0) or self.ai_state.self_compassion or 5
	local ally_compassion = (self.ai_state.ally_compassion == false and 0) or self.ai_state.ally_compassion or 1
	for tid, lvl in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		local t_avail = false
		print(self.name, self.uid, "tactical ai talents testing", t.name, tid)
		if t.tactical then
			local tg = self:getTalentTarget(t)
			local default_tg = {type=util.getval(t.direct_hit, self, t) and "hit" or "bolt"}
			-- Only assume range... some talents may no require LOS, etc
			local within_range = target_dist and target_dist <= (self:getTalentRange(t) + self:getTalentRadius(t))
			if t.mode == "activated" and not t.no_npc_use and
			   not self:isTalentCoolingDown(t) and self:preUseTalent(t, true, true) and
			   (not self:getTalentRequiresTarget(t) or within_range)
			   then
			   	t_avail = true
			elseif t.mode == "sustained" and not t.no_npc_use and not self:isTalentCoolingDown(t) and
			   not self:isTalentActive(t.id) and
			   self:preUseTalent(t, true, true)
			   then
			   	t_avail = true
			end
			if t_avail then
				-- Project the talent if possible, counting foes and allies hit
				local foes_hit = {}
				local allies_hit = {}
				local self_hit = {}
				local typ = engine.Target:getType(tg or default_tg)
				if tg or self:getTalentRequiresTarget(t) then
					local target_actor = self.ai_target.actor or self
					self:project(typ, target_actor.x, target_actor.y, function(px, py)
						local act = game.level.map(px, py, engine.Map.ACTOR)
						if act and not act.dead then
							if self:reactionToward(act) < 0 then
								print("[DEBUG] hit a foe!")
								foes_hit[#foes_hit+1] = act
							elseif (typ.selffire) and (act == self) then
								print("[DEBUG] hit self!")
								self_hit[#self_hit+1] = act
							elseif typ.friendlyfire then
								print("[DEBUG] hit an ally!")
								allies_hit[#allies_hit+1] = act
							end
						end
					end)
				end
				-- Evaluate the tactical weights and weight functions
				for tact, val in pairs(t.tactical) do
					if type(val) == "function" then val = val(self, t, self.ai_target.actor) or 0 end
					-- Handle damage_types and resistances
					local nb_foes_hit, nb_allies_hit, nb_self_hit = 0, 0, 0
					if type(val) == "table" then
						for damtype, damweight in pairs(val) do
							-- Allows a shortcut to just say FIRE instead of DamageType.FIRE in talent's tactical table
							damtype = DamageType[damtype] or damtype
							-- Checks a weapon's damtype
							if damtype == "weapon" then
								damtype = (weapon and weapon.damtype) or DamageType.PHYSICAL
							end
							local pen = 0
							if self.resists_pen then pen = (self.resists_pen.all or 0) + (self.resists_pen[damtype] or 0) end
							local check_resistance = function(actor_list)
								local weighted_sum = 0
								for i, act in ipairs(actor_list) do
									local res = math.min((act.resists.all or 0) + (act.resists[damtype] or 0), (act.resists_cap.all or 0) + (act.resists_cap[damtype] or 0))
									res = res * (100 - pen) / 100
									local damweight = damweight
									if type(damweight) == "function" then damweight = damweight(self, t, act) or 0 end
									-- Handles status effect immunity
									damweight = damweight * (act:canBe(damtype) and 1 or 0)
									weighted_sum = weighted_sum + damweight * (100 - res) / 100
								end
								return weighted_sum
							end
							nb_foes_hit = check_resistance(foes_hit)
							nb_self_hit = check_resistance(self_hit)
							nb_allies_hit = check_resistance(allies_hit)
						end
						val = 1
					-- Or assume no resistances
					else
						nb_foes_hit = #foes_hit
						nb_self_hit = #self_hit
						nb_allies_hit = #allies_hit
					end
					-- Apply the selffire and friendlyfire options
					nb_self_hit = nb_self_hit * (type(typ.selffire) == "number" and typ.selffire / 100 or 1)
					nb_allies_hit = nb_allies_hit * (type(typ.friendlyfire) == "number" and typ.friendlyfire / 100 or 1)
					-- Use the player set ai_talents weights
					val = val * (self.ai_talents and self.ai_talents[t.id] or 1) * (1 + lvl / 5)
					-- Update the weight by the dummy projection data
					-- Also force scaling if the talent requires a target (stand-in for canProject)
					if self:getTalentRequiresTarget(t) or nb_foes_hit > 0 or nb_allies_hit > 0 or nb_self_hit > 0 then
						val = val * (nb_foes_hit - ally_compassion * nb_allies_hit - self_compassion * nb_self_hit)
					end
					-- Only take values greater than 0... allows the ai_talents to turn talents off
					if val > 0 and not self:hasEffect(self.EFF_RELOADING) then
						if not avail[tact] then avail[tact] = {} end
						-- Save the tactic, if the talent is instant it gets a huge bonus
						-- Note the addition of a less than one random value, this means the sorting will randomly shift equal values
						val = ((t.no_energy==true) and val * 10 or val) + rng.float(0, 0.9)
						avail[tact][#avail[tact]+1] = {val=val, tid=tid, nb_foes_hit=nb_foes_hit, nb_allies_hit=nb_allies_hit, nb_self_hit=nb_self_hit}
						print(self.name, self.uid, "tactical ai talents can use", t.name, tid, tact, "weight", val)
						ok = true
					end
				end
			end
		end
	end
	if ok then
		local want = {}

		local need_heal = 0
		local life = 100 * self.life / self.max_life
		-- Subtract solipsism straight from the life value to give us higher than normal weights; helps keep clarity up and avoid solipsism
		if self:knowTalent(self.T_SOLIPSISM) then life = life - (100 * self:getPsi() / self:getMaxPsi()) end
		if life < 20 then need_heal = need_heal + 10 * self_compassion / 5
		elseif life < 30 then need_heal = need_heal + 8 * self_compassion / 5
		elseif life < 40 then need_heal = need_heal + 5 * self_compassion / 5
		elseif life < 60 then need_heal = need_heal + 4 * self_compassion / 5
		elseif life < 80 then need_heal = need_heal + 3 * self_compassion / 5
		end
		-- Need healing
		if avail.heal then
			want.heal = need_heal
		end

		-- Need mana
		if avail.mana then
			want.mana = 0
			local mana = 100 * self.mana / self.max_mana
			if mana < 20 then want.mana = want.mana + 4
			elseif mana < 30 then want.mana = want.mana + 3
			elseif mana < 40 then want.mana = want.mana + 2
			elseif mana < 60 then want.mana = want.mana + 2
			elseif mana < 80 then want.mana = want.mana + 1
			elseif mana < 100 then want.mana = want.mana + 0.5
			end
		end

		-- Need stamina
		if avail.stamina then
			want.stamina = 0
			local stamina = 100 * self.stamina / self.max_stamina
			if stamina < 20 then want.stamina = want.stamina + 4
			elseif stamina < 30 then want.stamina = want.stamina + 3
			elseif stamina < 40 then want.stamina = want.stamina + 2
			elseif stamina < 60 then want.stamina = want.stamina + 2
			elseif stamina < 80 then want.stamina = want.stamina + 1
			elseif stamina < 100 then want.stamina = want.stamina + 0.5
			end
		end

		-- Need vim
		if avail.vim then
			want.vim = 0
			local vim = 100 * self.vim / self.max_vim
			if vim < 20 then want.vim = want.vim + 4
			elseif vim < 30 then want.vim = want.vim + 3
			elseif vim < 40 then want.vim = want.vim + 2
			elseif vim < 60 then want.vim = want.vim + 2
			elseif vim < 80 then want.vim = want.vim + 1
			elseif vim < 100 then want.vim = want.vim + 0.5
			end
		end

		-- Need to reduce equilibrium
		if avail.equilibrium then
			want.equilibrium = 0
			local _, failure_chance = self:equilibriumChance()
			if failure_chance > 10 then want.equilibrium = want.equilibrium + 0.5
			elseif failure_chance > 20 then want.equilibrium = want.equilibrium + 1
			elseif failure_chance > 50 then want.equilibrium = want.equilibrium + 2
			elseif failure_chance > 60 then want.equilibrium = want.equilibrium + 4
			elseif failure_chance > 80 then want.equilibrium = want.equilibrium + 6
			end
		end

		-- Need to reduce paradox
		if avail.paradox then
			want.paradox = 0
			local _, failure_chance = self:paradoxFailChance()
			if failure_chance > 10 then want.paradox = want.paradox + 0.5
			elseif failure_chance > 20 then want.paradox = want.paradox + 1
			elseif failure_chance > 50 then want.paradox = want.paradox + 2
			elseif failure_chance > 60 then want.paradox = want.paradox + 4
			elseif failure_chance > 80 then want.paradox = want.paradox + 6
			end
		end

		-- Need ammo
		local a = self:hasAmmo()
		if avail.ammo and a and not self:hasEffect(self.EFF_RELOADING) then
			want.ammo = 0
			local ammo = 100 * a.combat.shots_left / a.combat.capacity
			if ammo == 0 then want.ammo = want.ammo + 10
			elseif ammo < 100 then want.ammo = want.ammo + 0.5
			end
		end

		-- Summoner needs protection
		if avail.protect and self.summoner then
			want.protect = 0
			local life = 100 * self.summoner.life / self.summoner.max_life
			if life < 20 then want.protect = want.protect + 10 * ally_compassion
			elseif life < 30 then want.protect = want.protect + 8 * ally_compassion
			elseif life < 40 then want.protect = want.protect + 5 * ally_compassion
			elseif life < 60 then want.protect = want.protect + 4 * ally_compassion
			elseif life < 80 then want.protect = want.protect + 3 * ally_compassion
			end
		end

		-- Need closing-in
		if avail.closein and target_dist and target_dist > 2 and self.ai_tactic.closein then
			want.closein = 1 + target_dist / 2
		end

		-- Need escaping... allow escaping even if there isn't a talent so we can flee
		if target_dist and (avail.escape or canFleeDmapKeepLos(self)) then
			want.escape = need_heal / 2
			if self.ai_tactic.safe_range and target_dist < self.ai_tactic.safe_range then want.escape = want.escape + self.ai_tactic.safe_range / 2 end
		end

		-- Surrounded
		local nb_foes_seen = 0
		local nb_allies_seen = 0
		local arr = self.fov.actors_dist
		local act
		local sqsense = 2 * 2
		for i = 1, #arr do
			act = self.fov.actors_dist[i]
			if act and not act.dead and self.fov.actors[act] and self.fov.actors[act].sqdist <= sqsense then
				if self:reactionToward(act) < 0 then
					nb_foes_seen = nb_foes_seen + 1
				else
					nb_allies_seen = nb_allies_seen + 1
				end
			end
		end

		if avail.surrounded then
			want.surrounded = nb_foes_seen
		end

		-- Need defence
		if avail.defend and need_heal and nb_foes_seen > 0 then
			table.sort(avail.defend, function(a,b) return a.val > b.val end)
			want.defend = 1 + need_heal / 2 + nb_foes_seen * 0.5
		end

		-- Need cure (remove detrimental effects)
		local nb_detrimental_effs = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				nb_detrimental_effs = nb_detrimental_effs + 1
			end
		end
		if avail.cure and nb_detrimental_effs > 0 then
			table.sort(avail.cure, function(a,b) return a.val > b.val end)
			want.cure = nb_detrimental_effs
		end

		-- Attacks
		if avail.attack and self.ai_target.actor then
			-- Use the foe/ally ratio from the best attack talent
			table.sort(avail.attack, function(a,b) return a.val > b.val end)
			want.attack = avail.attack[1].val
		end
		if avail.disable and self.ai_target.actor then
			-- Use the foe/ally ratio from the best disable talent
			table.sort(avail.disable, function(a,b) return a.val > b.val end)
			want.disable = (want.attack or 0) + avail.disable[1].val
		end
		if avail.attackarea and self.ai_target.actor then
			-- Use the foe/ally ratio from the best attackarea talent
			table.sort(avail.attackarea, function(a,b) return a.val > b.val end)
			want.attackarea = avail.attackarea[1].val
		end

		-- Need buffs
		if avail.buff and want.attack and want.attack > 0 then
			want.buff = math.max(0.01, want.attack + 0.5)
		end

		print("Tactical ai report for", self.name)
		local res = {}
		for k, v in pairs(want) do
			if v > 0 then
				-- Randomize and multiply by the ai_tactic weights (if any)
				v = (v + v + rng.float(0, 0.9)) * (self.ai_tactic[k] or 1)
				if v > 0 then
					print(" * "..k, v, "(mult)", self.ai_tactic[k])
					res[#res+1] = {k,v}
				end
			end
		end
		if #res == 0 then return end
		table.sort(res, function(a,b) return a[2] > b[2] end)
		local selected_talents = avail[res[1][1]]
		if selected_talents then
			table.sort(selected_talents, function(a,b) return a.val > b.val end)
			local tid = selected_talents[1].tid
			print("Tactical choice:", res[1][1], tid)
			self:useTalent(tid)
			return true
		else
			return nil, res[1][1]
		end
	end
end)

newAI("tactical", function(self)
	local targeted = self:runAI(self.ai_state.ai_target or "target_simple")

	-- Keep your distance
	local special_move = false
	if self.ai_tactic.safe_range and self.ai_target.actor and self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y) then
		local target_dist = core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)
		if self.ai_tactic.safe_range == target_dist then
			special_move = "none"
		elseif self.ai_tactic.safe_range > target_dist then
			special_move = "flee_dmap_keep_los"
		end
	end

	local used_talent, want
	-- One in "talent_in" chance of using a talent
	if (not self.ai_state.no_talents or self.ai_state.no_talents == 0) and rng.chance(self.ai_state.talent_in or 2) then
		used_talent, want = self:runAI("use_tactical")
	end

	if want == "escape" then
		special_move = "flee_dmap_keep_los"
	end

	if targeted and not self.energy.used then
		if special_move then
			return self:runAI(special_move)
		else
			return self:runAI(self.ai_state.ai_move or "move_simple")
		end
	end
	return false
end)

newAI("flee_dmap_keep_los", function(self)
	local can_flee, fx, fy = canFleeDmapKeepLos(self)
	if can_flee then
		return self:move(fx, fy)
	end
end)

