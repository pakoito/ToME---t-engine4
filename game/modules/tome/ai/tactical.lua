-- Randomly use talents
newAI("use_tactical", function(self)
	-- Find available talents
	print("============================== TACTICAL AI", self.name)
	local avail = {}
	local ok = false
	local target_dist = self.ai_target.actor and math.floor(core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y))
	local hate = self.ai_target.actor and (self:reactionToward(self.ai_target.actor) < 0)
	local has_los = self.ai_target.actor and self:hasLOS(self.ai_target.actor.x, self.ai_target.actor.y)
	for tid, lvl in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
--		print(self.name, self.uid, "dumb ai talents can try use", t.name, tid, "::", t.mode, not self:isTalentCoolingDown(t), target_dist <= self:getTalentRange(t), self:preUseTalent(t, true), self:canProject({type="bolt"}, self.ai_target.actor.x, self.ai_target.actor.y))
		if t.mode == "activated" and
		   not self:isTalentCoolingDown(t) and
		   self:preUseTalent(t, true, true) and
		   (not t.requires_target or (
		     hate and
		     target_dist <= self:getTalentRange(t) and
		     self:canProject({type=util.getval(t.direct_hit, self, t) and "hit" or "bolt"}, self.ai_target.actor.x, self.ai_target.actor.y) and
		     has_los
		   ))
		   then
			if t.tactical then
				for tact, val in pairs(t.tactical) do
					if not avail[tact] then avail[tact] = {} end
					-- Save the tactic, if the talent is instant it gets a huge bonus
					-- Note the addition of a less than one random value, this means the sorting will randomly shift equal values
					val = val * (1 + lvl / 5)
					avail[tact][#avail[tact]+1] = {val=((t.no_energy==true) and val * 10 or val) + rng.float(0, 0.9), tid=tid}
					print(self.name, self.uid, "tactical ai talents can use", t.name, tid, tact)
					ok = true
				end
			end
		elseif t.mode == "sustained" and not self:isTalentCoolingDown(t) and
		   not self:isTalentActive(t.id) and
		   self:preUseTalent(t, true, true)
		   then
			avail[#avail+1] = t
			print(self.name, self.uid, "tactical ai talents can activate", t.name, tid)
		end
	end
	if ok then
		local want = {}

		local need_heal = 0
		local life = 100 * self.life / self.max_life
		if life < 20 then need_heal = need_heal + 10
		elseif life < 30 then need_heal = need_heal + 8
		elseif life < 40 then need_heal = need_heal + 5
		elseif life < 60 then need_heal = need_heal + 4
		elseif life < 80 then need_heal = need_heal + 3
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
		local nb_foes = 0
		local arr = self.fov.actors_dist
		local act
		local sqsense = 2 * 2
		for i = 1, #arr do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and not act.dead and self.fov.actors[act].sqdist <= sqsense then nb_foes = nb_foes + 1 end
		end

		if avail.surrounded then
			want.surrounded = nb_foes
		end

		-- Need defence
		if avail.defend then
			want.defend = 1 + need_heal / 2 + nb_foes * 0.5
		end

		if avail.disable then want.disable = 2 end
		if avail.attack then want.attack = 1 end
		if avail.attackarea then want.attackarea = (want.attack or 0) + nb_foes * 0.6 end

		print("Tactical ai report for", self.name)
		local res = {}
		for k, v in pairs(want) do
					print(" * "..k, v)
			if v > 0 then
				v = (v + v + rng.float(0, 0.9)) * (self.ai_tactic[k] or 1)
					print(" * "..k, v)
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

	-- One in "talent_in" chance of using a talent
	if (not self.ai_state.no_talents or self.ai_state.no_talents == 0) and rng.chance(self.ai_state.talent_in or 2) then
		self:runAI("use_tactical")
	end

	if targeted and not self.energy.used then
		self:runAI(self.ai_state.ai_move or "move_simple")
	end
	return true
end)
