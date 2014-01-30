-- TE4 - T-Engine 4
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

require "engine.class"
local lpeg = require "lpeg"

module(..., package.seeall, class.make)

--- Creates a random name generator using a pregenerated grammar
function _M:init(file)
	print("Loading language", file)
	local f = fs.open(file, "r")
	local lines = {}
	while true do
		local line = f:readLine()
		if not line then break end
		lines[#lines+1] = line
	end
	f:close()

	-- First line, list of syllables
	self.syllables = lines[1]:split(',')

	-- Next 2 lines, start syllable indexes and counts
	self.starts = {}
	local start_ids = lines[2]:split(',')
	for i, cnt in ipairs(lines[3]:split(',')) do self.starts[#self.starts+1] = {s=tonumber(start_ids[i]), c=tonumber(cnt)} end

	-- Next 2, same for syllable ends
	self.ends = {}
	local end_ids = lines[4]:split(',')
	for i, cnt in ipairs(lines[5]:split(',')) do self.ends[#self.ends+1] = {s=tonumber(end_ids[i]), c=tonumber(cnt)} end

	-- Starting with the 6th and 7th lines, each pair of lines holds ids and counts of the "next syllables" for a previous syllable.
	self.combinations = {}
	for i = 6, #lines, 2 do
		local ids_str, counts_str = lines[i], lines[i+1]
		if #ids_str == 0 or #counts_str == 0 then table.insert(self.combinations, {})
		else
			comb = {}
			local ids = ids_str:split(',')
			for i, cnt in ipairs(counts_str:split(',')) do comb[#comb+1] = {s=tonumber(ids[i]), c=tonumber(cnt)} end
			table.insert(self.combinations, comb)
		end
	end

	self.min_syl = 2
	self.max_syl = 3
	self.forbidden = {}
end

--- Generates a name
function _M:generate(no_repeat, min_syl, max_syl)
	min_syl = min_syl or self.min_syl
	max_syl = max_syl or self.max_syl

	-- Random number of syllables, the last one is always appended
	local num_syl = rng.range(min_syl, max_syl)

	-- Turn ends list of tuples into a dictionary
	local ends_dict = table.from_list(self.ends, 's', 'c')

	-- We may have to repeat the process if the first "min_syl" syllables were a bad choice
	-- and have no possible continuations; or if the word is in the forbidden list.
	local word = {}
	local word_str = ''
	local used = {}
	while #word < self.min_syl or self.forbidden[word_str] do
		-- start word with the first syllable
		local syl = self:selectSyllable(self.starts, 0, used)
		word = {self.syllables[syl]}

		local done_end = false
		for i = 1, num_syl - 2 do
			-- don't end yet if we don't have the minimum number of syllables
			local eend
			if i < min_syl then eend = 0
			else eend = ends_dict[syl] or 0 -- probability of ending for this syllable
			end

			-- select next syllable
			syl = self:selectSyllable(self.combinations[syl], eend, used)
			if not syl then done_end = true break end -- early end for this word, end syllable was chosen

			word[#word+1] = self.syllables[syl]
		end

		if not done_end then
			-- forcefully add an ending syllable if the loop ended without one
			syl = self:selectSyllable(self.ends, 0, used)
			word[#word+1] = self.syllables[syl]
		end

		print("Make word from", table.concat(word, ", "), num_syl)
		word_str = table.concat(word)
	end

	-- to ensure the word doesn't repeat, add it to the forbidden words
	if no_repeat then self.forbidden[word_str] = true end

	return word_str:capitalize()
end

function _M:selectSyllable(counts, end_count, used, tries)
	tries = tries or 50
	if not counts or #counts == 0 or tries <= 0 then return end

	-- "counts" holds cumulative counts, so take the last element in the list
	-- (and 2nd in that tuple) to get the sum of all counts
	local chosen = rng.range(0, counts[#counts].c + end_count)

	for _, d in ipairs(counts) do
		if d.c >= chosen then
			if used[d.s] then return self:selectSyllable(counts, end_count, used, tries - 1) end
			used[d.s] = true
			return d.s
		end
	end
end
