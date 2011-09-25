#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "dmm.h"

void PlaceTG(ZLevel *zl, int x, int y, TileGroup *tg)
{
	for(int _x = x; _x < x+tg->width; _x++)
		for(int _y = y; _y < y+tg->height; _y++)
			station.tiles[_x][_y] = tg->tiles[(_x - x) + (_y - y)*tg->width];
}

void PlaceTG(string name)
{
	TileGroup *tg = LoadTileGroup(("input/"  +name + ".dmm").c_str());
	if(!tg)
	{
		printf("Failed to load tilegroup %s\n", name.c_str());
		exit(1);
	}
	int x, y;
	if(!station.AllocateRect(tg->width, tg->height, x, y))
	{
		printf("Failed to allocate space for %ix%i tiles (for tilegroup %s)\n", tg->width, tg->height, name.c_str());
		delete tg;
		exit(1);
	}
	PlaceTG(&station, x, y, tg);
	delete tg;
	printf("Placed tilegroup %s\n", name.c_str());
}

int main(int argc, char **argv)
{
	srand(time(NULL));

	PlaceTG("pregame");
	PlaceTG("engine");

	WriteDMM();
	return 0;
}