#include <stdlib.h>
#include "display.h"
#include "script.h"
#include "map.h"

void init_map(map m, int w, int h)
{
	int i, j;

	m->grids = calloc(w * h, sizeof(grid*));
	m->seens = calloc(w * h, sizeof(bool));
	m->remembers = calloc(w * h, sizeof(bool));
	m->w = w;
	m->h = h;
	for (i = 0; i < w; i++)
		for (j = 0; j < h; j++)
		{
			m->grids[i + j * w] = NULL;
			m->seens[i + j * w] = FALSE;
			m->remembers[i + j * w] = FALSE;
		}
}

map new_map(int w, int h)
{
	map m = malloc(sizeof(map));
	init_map(m, w, h);
	return m;
}

void free_map(map m)
{
	int i, j;

	for (i = 0; i < m->w; i++)
		for (j = 0; j < m->h; j++)
		{
			grid g = m->grids[i + j * m->w];
			while (g)
			{
				grid next = g->next;
				free(g);
				g = next;
			}
		}
	free(m->grids);
	free(m->seens);
	free(m);
}

void map_delete_grid_all(map m, int x, int y)
{
	grid g = m->grids[i + j * m->w];
	while (g)
	{
		grid next = g->next;
		free(g);
		g = next;
	}
}

void map_insert_grid(map m, int x, int y, int pos, long uid)
{
	grid g;
	if (!m) return;
	if ((x < 0) || (y < 0) || (x >= m->w) || (y >= m->h)) return;

	g = m->grids[x + y * m->w];
	while (g)
	{
		if (g->uid == uid) break;
		g = g->next;
	}

	/* Not present, add it */
	if (!g)
	{
		int i = 1;
		g = m->grids[x + y * m->w];
		grid prev = NULL;
		while (g && i < pos)
		{
			i++;
			prev = g;
			g = g->next;
		}
		if (i == 1)
		{
			grid next = m->grids[x + y * m->w];
			g = m->grids[x + y * m->w] = calloc(1, sizeof(struct grid_type));
			g->uid = uid;
			g->next = next;
		}
		else
		{
			grid next = g;
			g = calloc(1, sizeof(struct grid_type));
			g->uid = uid;
			g->next = next;
			prev->next = g;
		}
	}
}

long map_get_grid(map m, int x, int y, int pos)
{
	int i = 1;

	if (!m) return;
	if ((x < 0) || (y < 0) || (x >= m->w) || (y >= m->h)) return;

	grid g = m->grids[x + y * m->w];
	while (g && i++ < pos) g = g->next;
	if (g) return g->uid;
	else return 0;
}

void map_display(map m)
{
	int i, j;

	for (i = 0; i < m->w; i++)
		for (j = 0; j < m->h; j++)
		{
			if (m->grids[i + j * m->w])
			{
				unsigned char r, g, b;
				char *c;
				lua_getglobal(L, "__uids");
				lua_pushnumber(L, m->grids[i + j * m->w]->uid);
				lua_gettable(L, -2);

				lua_pushstring(L, "color_r");
				lua_gettable(L, -2);
				r = lua_tonumber(L, 4);
				lua_pop(L, 1);

				lua_pushstring(L, "color_g");
				lua_gettable(L, -2);
				g = lua_tonumber(L, 4);
				lua_pop(L, 1);

				lua_pushstring(L, "color_b");
				lua_gettable(L, -2);
				b = lua_tonumber(L, 4);
				lua_pop(L, 1);

				lua_pushstring(L, "display");
				lua_gettable(L, -2);
				c = lua_tostring(L, 4);
				lua_pop(L, 1);

				lua_pop(L, 2);

				if (m->seens[i + j * m->w])
					display_put_char(c, i, j, r, g, b);
				else if (m->remembers[i + j * m->w])
					display_put_char(c, i, j, r/3, g/3, b/3);
			}

			m->seens[i + j * m->w] = FALSE;
		}
}
