#include "dmm.h"
#include <stdlib.h>

ZLevel station;

Tile::Tile()
{
	turf = new Object;
	turf->path = "/turf/space";
    area = "/area";
	objects.push_back(turf);
}

bool ZLevel::AllocateRect(int w, int h, int &x, int &y)
{
	for(int tries = 0; tries < 100; tries++)
	{
		x = int(rand() * double(MAP_W - w) / RAND_MAX);
		y = int(rand() * double(MAP_H - h) / RAND_MAX);
		bool ok = true;
		for(int _x = 0; _x < w; _x++)
		{
			for(int _y = 0; _y < h; _y++)
			{
				if(tile_used[x+_x][y+_y])
				{
					ok = false;
					break;
				}
			}
			if(!ok)
				break;
		}
		if(ok)
		{
			for(int _x = 0; _x < w; _x++)
				for(int _y = 0; _y < h; _y++)
					tile_used[x+_x][y+_y] = true;
			return true;
		}
	}
	return false;
}