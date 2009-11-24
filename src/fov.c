#include "fov.h"
#include "types.h"
#include "script.h"
#define f(x,y) for (x = 0; x < y; ++x)

int ccw(int x1, int y1, int x2, int y2, int x3, int y3) {	// positive iff they are counterclockwise
	return (x1*y2 + x2*y3 + x3*y1 - x1*y3 - x2*y1 - x3*y2);
}

static bool check(int map_ref, int check_ref, int x, int y)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, check_ref);
	lua_rawgeti(L, LUA_REGISTRYINDEX, map_ref);
	lua_pushnumber(L, x);
	lua_pushnumber(L, y);
	lua_call(L, 3, 1);
	bool res = lua_toboolean(L, -1);
	lua_pop(L, 1);
	return res;
}

static void apply(int map_ref, int apply_ref, int px, int py, int cx, int cy, int dis)
{
	if ((cx-px)*(cx-px) + (cy-py)*(cy-py) <= dis*dis + 1) {	// circular view - can be changed if you like
		lua_rawgeti(L, LUA_REGISTRYINDEX, apply_ref);
		lua_rawgeti(L, LUA_REGISTRYINDEX, map_ref);
		lua_pushnumber(L, cx);
		lua_pushnumber(L, cy);
		lua_pushnumber(L, dis);
		lua_call(L, 4, 0);
	}
}

// runs in O(N), "point" (read: unit length segment) to "point" line of sight that also checks intermediate "point"s.
// Gives identical results to the other algorithm, amazingly. Both are equivalent to checking for digital lines.
// you see those inner loops? Amortized time. Each while loop is entered at most N times, total.
static void trace(int src_x, int src_y, int dir, int n, int h, int map_ref, int check_ref, int apply_ref)
{
	int topx[n+2], topy[n+2], botx[n+2], boty[n+2];	// convex hull of obstructions
	int curt = 0, curb = 0;	// size of top and bottom convex hulls
	int s[2][2] = {{0, 0}, {0, 0}};	// too lazy to think of real variable names, four critical points on the convex hulls - these four points determine what is visible
	topx[0] = botx[0] = boty[0] = 0, topy[0] = 1;
	int ad1 = 1, ad2[2] = {0, 0}, eps[2] = {0, n-1};
	for (; ad1 <= n; ++ad1) {
		int i;
		f(i,2) {
			eps[i] += h;	// good old Bresenham
			if (eps[i] >= n) {
				eps[i] -= n;
				++ad2[i];
			}
		}
		f(i,2) if (ccw(topx[s[!i][1]], topy[s[!i][1]], botx[s[i][0]], boty[s[i][0]], ad1, ad2[i]+i) <= 0) return;	// the relevant region is no longer visible. If we don't exit the loop now, strange things happen.
		int cx[2] = {ad1, ad1}, cy[2] = {ad2[0], ad2[1]};
		f(i,2) {
			if (dir&1) cx[i] = -cx[i];
			if (dir&2) cy[i] = -cy[i];
			if (dir&4) cx[i] ^= cy[i], cy[i] ^= cx[i], cx[i] ^= cy[i];
			cx[i] += src_x, cy[i] += src_y;

			if (ccw(topx[s[i][1]], topy[s[i][1]], botx[s[!i][0]], boty[s[!i][0]], ad1, ad2[i]+1-i) > 0) {
				apply(map_ref, apply_ref, src_x, src_y, cx[i], cy[i], n);
			}
		}

		if (check(map_ref, check_ref, cx[0], cy[0])) {	// new obstacle, update convex hull
			++curb;
			botx[curb] = ad1, boty[curb] = ad2[0]+1;
			if (ccw(botx[s[0][0]], boty[s[0][0]], topx[s[1][1]], topy[s[1][1]], ad1, ad2[0]+1) >= 0) return;	// the obstacle obscures everything
			if (ccw(topx[s[0][1]], topy[s[0][1]], botx[s[1][0]], boty[s[1][0]], ad1, ad2[0]+1) >= 0) {
				s[1][0] = curb;	// updating visible region
				while (s[0][1] < curt && ccw(topx[s[0][1]], topy[s[0][1]], topx[s[0][1]+1], topy[s[0][1]+1], ad1, ad2[0]+1) >= 0) ++s[0][1];
			}
			while (curb > 1 && ccw(botx[curb-2], boty[curb-2], botx[curb-1], boty[curb-1], ad1, ad2[0]+1) >= 0) {	// not convex anymore, delete a point
				if (s[1][0] == curb) --s[1][0];	// s[0][0] won't be a problem
				--curb;
				botx[curb] = botx[curb+1], boty[curb] = boty[curb+1];
			}
		}

		if (check(map_ref, check_ref, cx[1], cy[1])) {	// same as above
			++curt;
			topx[curt] = ad1, topy[curt] = ad2[1];
			if (ccw(botx[s[1][0]], boty[s[1][0]], topx[s[0][1]], topy[s[0][1]], ad1, ad2[1]) >= 0) return;
			if (ccw(topx[s[1][1]], topy[s[1][1]], botx[s[0][0]], boty[s[0][0]], ad1, ad2[1]) >= 0) {
				s[1][1] = curt;
				while (s[0][0] < curb && ccw(botx[s[0][0]], boty[s[0][0]], botx[s[0][0]+1], boty[s[0][0]+1], ad1, ad2[1]) <= 0) ++s[0][0];
			}
			while (curt > 1 && ccw(topx[curt-2], topy[curt-2], topx[curt-1], topy[curt-1], ad1, ad2[1]) <= 0) {
				if (s[1][1] == curt) --s[1][1];
				--curt;
				topx[curt] = topx[curt+1], topy[curt] = topy[curt+1];
			}
		}
	}
}

void do_fov(int x, int y, int distance, int map_ref, int check_ref, int apply_ref)
{
	int dir;
	f(dir, 8) {
		int i;
		f(i,distance+1) trace(x, y, dir, distance, i, map_ref, check_ref, apply_ref);
	}
}
