-- TE4 - T-Engine 4
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

require "engine.class"

--- Abstract binary space partitioning
-- Can be used to generator levels and so on
module(..., package.seeall, class.make)

function _M:init(w, h, min_w, min_h, max_depth)
	self.max_depth = max_depth or 8
	self.min_w, self.min_h = min_w, min_h
	self.node_id = 1
	self.splits = { vert={}, hor={} }
	self.leafs = {}
	self.bsp = {x=0, y=0, rx=0, ry=0, w=w, h=h, nodes={}, id=0, depth=0}
	print("[BSP] ", w, h)
end

function _M:partition(store)
	store = store or self.bsp

	local split_vert, split_hor = false, false
	if store.w >= self.min_w * 2 then split_hor = true end
	if store.h >= self.min_h * 2 then split_vert = true end
	print("[BSP] "..store.id.." partitioning", store.rx, store.ry, "::", store.w, store.h, " splits ", split_hor, split_vert)

	if split_vert and split_hor then
		local ok = rng.percent(50)
		split_vert, split_hor = ok, not ok
	end

	if store.depth > self.max_depth then split_vert, split_hor = false, false end

	if split_vert and not split_hor then
		local s = rng.range(self.min_h, store.h - self.min_h)
--		print("[BSP] vertical split", s)
		store.nodes[1] = {depth=store.depth+1, x=0, y=0, rx=store.rx, ry=store.ry, w=store.w, h=s, dir=2, nodes={}, id=self.node_id} self.node_id = self.node_id + 1
		store.nodes[2] = {depth=store.depth+1, x=0, y=s, rx=store.rx, ry=store.ry + s, w=store.w, dir=8, h=store.h - s, nodes={}, id=self.node_id} self.node_id = self.node_id + 1
		self.splits.vert[store.ry + s] = {min=store.rx, max=store.rx+store.w}
		self:partition(store.nodes[1])
		self:partition(store.nodes[2])

	elseif not split_vert and split_hor then
		local s = rng.range(self.min_w, store.w - self.min_w)
--		print("[BSP] horizontal split", s)
		store.nodes[1] = {depth=store.depth+1, x=0, y=0, rx=store.rx, ry=store.ry, w=s, h=store.h, dir=6, nodes={}, id=self.node_id} self.node_id = self.node_id + 1
		store.nodes[2] = {depth=store.depth+1, x=s, y=0, rx=store.rx + s, ry=store.ry, w=store.w -s, h=store.h, dir=4, nodes={}, id=self.node_id} self.node_id = self.node_id + 1
		self.splits.hor[store.rx + s] = {min=store.ry, max=store.ry+store.h}
		self:partition(store.nodes[1])
		self:partition(store.nodes[2])
	end

	if #store.nodes == 0 then self.leafs[#self.leafs+1] = store end
end
