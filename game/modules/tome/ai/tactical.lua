-- Randomly use talents
newAI("use_tactical", function(self)
	-- Find available talents
	print("============================== TACTICAL AI", self.name)
	local avail = {}
	local ok = false
	local target_dist = self.ai_target.actor and math.floor(core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y))
	local hate = self.ai_target.actor and (self:reactionToward(self.ai_target.actor) < 0)
	local has_los = self.ai_target.actor and self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y)
	local self_compassion = (self.ai_state.self_compassion == false and 0) or self.ai_state.self_compassion or 5
	local ally_compassion = (self.ai_state.ally_compassion == false and 0) or self.ai_state.ally_compassion or 1
	for tid, lvl in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		local t_avail = false
		print(self.name, self.uid, "tactical ai talents testing", t.name, tid)
		if t.tactical then
			local tg = self:getTalentTarget(t) or {type=util.getval(t.direct_hit, self, t) and "hit" or "bolt"}
			if t.mode == "activated" and not t.no_npc_use and
			   not self:isTalentCoolingDown(t) and
			   self:preUseTalent(t, true, true) and
			   (not self:getTalentRequiresTarget(t) or (
				 hate and
				 target_dist <= (self:getTalentRange(t) + self:getTalentRadius(t)) and
				 self:canProject(tg, self.ai_target.actor.x, self.ai_target.actor.y) and
				 has_los
			   ))
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
				local nb_foes_hit, nb_allies_hit, nb_self_hit
				if tg then
					local typ = engine.Target:getType(tg)
					local target_actor = self.ai_target.actor or self
					nb_foes_hit = 0
					nb_allies_hit = 0
					nb_self_hit = 0
					self:project(typ, target_actor.x, target_actor.y, function(px, py)
						local act = game.level.map(px, py, engine.Map.ACTOR)
						if act and not act.dead then
							if self:reactionToward(act) < 0 then
								print("[DEBUG] hit a foe!")
								nb_foes_hit = nb_foes_hit + 1
							elseif (typ.selffire) and (act == self) then
								print("[DEBUG] hit self!")
								nb_self_hit = nb_self_hit + (type(typ.selffire) == "number" and typ.selffire / 100 or 1)
							elseif typ.friendlyfire then
								print("[DEBUG] hit an ally!")
								nb_allies_hit = nb_allies_hit + (type(typ.friendlyfire) == "number" and typ.friendlyfire / 100 or 1)
							end
						end
					end)
				end
				-- Evaluate the tactical weights and weight functions
				for tact, val in pairs(t.tactical) do
					if not avail[tact] then avail[tact] = {} end
					-- Save the tactic, if the talent is instant it gets a huge bonus
					-- Note the addition of a less than one random value, this means the sorting will randomly shift equal values
					if type(val) == "function" then val = val(self, t, self.ai_target.actor) end
					val = val * (1 + lvl / 5)
					if nb_foes_hit and (nb_foes_hit > 0 or nb_allies_hit > 0 or nb_self_hit > 0) then
						val = val * math.max(0.01, nb_foes_hit - ally_compassion * nb_allies_hit - self_compassion * nb_self_hit)
					end
					avail[tact][#avail[tact]+1] = {val=((t.no_energy==true) and val * 10 or val) + rng.float(0, 0.9), tid=tid, nb_foes_hit=nb_foes_hit, nb_allies_hit=nb_allies_hit, nb_self_hit=nb_self_hit}
					print(self.name, self.uid, "tactical ai talents can use", t.name, tid, tact, "weight", avail[tact][#avail[tact]].val)
					ok = true
				end
			end
		end
	end
	if ok then
		local want = {}

		local need_heal = 0
		local life = 100 * self.life / self.max_life
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
			local _, failure_chance = self:paradoxChance()
			if failure_chance > 10 then want.paradox = want.paradox + 0.5
			elseif failure_chance > 20 then want.paradox = want.paradox + 1
			elseif failure_chance > 50 then want.paradox = want.paradox + 2
			elseif failure_chance > 60 then want.paradox = want.paradox + 4
			elseif failure_chance > 80 then want.paradox = want.paradox + 6
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

		-- Need escaping
		if avail.escape and target_dist then
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

		-- Attacks
		if avail.attack and self.ai_target.actor then
			-- Use the foe/ally ratio from the best attack talent
			table.sort(avail.attack, function(a,b) return a.val > b.val end)
			want.attack = (avail.attack[1].nb_foes_hit or 1) - ally_compassion * (avail.attack[1].nb_allies_hit or 0) - self_compassion * (avail.attack[1].nb_self_hit or 0)
		end
		if avail.disable and self.ai_target.actor then
			-- Use the foe/ally ratio from the best disable talent
			table.sort(avail.disable, function(a,b) return a.val > b.val end)
			want.disable = (want.attack or 0) + (avail.disable[1].nb_foes_hit or 1) - ally_compassion * (avail.disable[1].nb_allies_hit or 0) - self_compassion * (avail.disable[1].nb_self_hit or 0)
		end
		if avail.attackarea and self.ai_target.actor then
			-- Use the foe/ally ratio from the best attackarea talent
			table.sort(avail.attackarea, function(a,b) return a.val > b.val end)
			want.attackarea = (want.attack or 0) + (avail.attackarea[1].nb_foes_hit or nb_foes_seen) - ally_compassion * (avail.attackarea[1].nb_allies_hit or nb_allies_seen) - self_compassion * (avail.attackarea[1].nb_self_hit or 0)
		end

		-- Need buffs
		if avail.buff and want.attack and want.attack > 0 then
			want.buff = math.max(0.01, want.attack - 1)
		end

		print("Tactical ai report for", self.name)
		local res = {}
		for k, v in pairs(want) do
			if v > 0 then
				v = (v + v + rng.float(0, 0.9)) * (self.ai_tactic[k] or 1)
				if v > 0 then
					print(" * "..k, v)
					res[#res+1] = {k,v}
				end
			end
		end
		table.sort(res, function(a,b) return a[2] > b[2] end)
		res = res[1]
		if not res then return end
		avail = avail[res[1]]
		table.sort(avail, function(a,b) return a.val > b.val end)

		if avail[1] then
			local tid = avail[1].tid
			print("Tactical choice:", res[1], tid)
			self:useTalent(tid)
			return true
		end
	end
end)

newAI("tactical", function(self)
	local targeted = self:runAI(self.ai_state.ai_target or "target_simple")

	-- Keep your distance
	local special_move = false
	if self.ai_tactic.safe_range and self.ai_target.actor and self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y) then
		local target_dist = math.floor(core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y))
		if self.ai_tactic.safe_range == target_dist then
			special_move = "none"
		elseif self.ai_tactic.safe_range > target_dist then
			special_move = "flee_dmap_keep_los"
		end
	end

	-- One in "talent_in" chance of using a talent
	if (not self.ai_state.no_talents or self.ai_state.no_talents == 0) and rng.chance(self.ai_state.talent_in or 2) then
		self:runAI("use_tactical")
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

local checkLOS = function(sx, sy, tx, ty)
	what = what or "block_sight"
	local l = line.new(sx, sy, tx, ty)
	local lx, ly = l()
	while lx and ly do
		if game.level.map:checkAllEntities(lx, ly, what) then break end

		lx, ly = l()
	end
	-- Ok if we are at the end reset lx and ly for the next code
	if not lx and not ly then lx, ly = x, y end

	if lx == x and ly == y then return true, lx, ly end
	return false, lx, ly
end

newAI("flee_dmap_keep_los", function(self)
	if self.ai_target.actor then
		local a = self.ai_target.actor

		local c = a:distanceMap(self.x, self.y)
		if not c then return end
		local dir = 5
		for i = 1, 9 do
			local sx, sy = util.coordAddDir(self.x, self.y, i)
			-- Check LOS first
			if checkLOS(sx, sy, a.x, a.y) then
				local cd = a:distanceMap(sx, sy)
	--			print("looking for dmap", dir, i, "::", c, cd)
				if not cd or (c and (cd < c and self:canMove(sx, sy))) then c = cd; dir = i end
			end
		end
		
		-- Check if we are in melee
		-- EVENTUALLY
		
		return self:moveDirection(util.coordAddDir(self.x, self.y, dir))
	end
end)
