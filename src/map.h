#ifndef MAP_H
#define MAP_H

#include "types.h"

typedef struct grid_type* grid;
struct grid_type
{
	long uid;
	grid next;
};

typedef struct map_type* map;
struct map_type
{
	int w, h;
	grid* grids;
	bool* seens;
	bool* remembers;
};

// Handle maps
void init_map(map m, int w, int h);
map new_map(int w, int h);
void free_map(map m);
void map_insert_grid(map m, int x, int y, int pos, long uid);
long map_get_grid(map m, int x, int y, int pos);


#endif
