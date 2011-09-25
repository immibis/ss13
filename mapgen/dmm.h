#pragma once

#include <string>
#include <list>
#include <map>

using std::string;
using std::list;
using std::map;

#define MAP_W 180
#define MAP_H 180

struct Object
{
	string path;
	map<string, string> attrib; // values are complete expressions, eg strings are enclosed in quote marks
};

struct Tile
{
	Object *turf;
    string area;
	list<Object*> objects; // includes turf
	Tile();
};

struct TileGroup
{
    const int width;
    const int height;
    Tile *tiles;
    TileGroup(int w, int h) : width(w), height(h)
    {
        tiles = new Tile[w*h];
    }
    ~TileGroup() {delete [] tiles;}
};

struct ZLevel
{
	Tile tiles[MAP_W][MAP_H];
    bool tile_used[MAP_W][MAP_H];

	// returns true on success
    bool AllocateRect(int w, int h, int &x, int &y);
};

extern ZLevel station;

void WriteDMM();
TileGroup *LoadTileGroup(const char *fn);
