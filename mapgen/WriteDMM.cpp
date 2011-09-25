#include <stdio.h>
#include "dmm.h"

static string GetObjectDef(Object *o)
{
	string str = o->path;
	if(o->attrib.size() == 0)
		return str;
	str += "{";
	for(map<string, string>::iterator it = o->attrib.begin(); it != o->attrib.end(); it++)
	{
		if(it != o->attrib.begin())
			str += "; ";
		str += it->first + " = " + it->second;
	}
	str += "}";
	return str;
}

static string GetTileDef(Tile *t)
{
	string str = "(";
	for(list<Object*>::iterator it = t->objects.begin(); it != t->objects.end(); it++)
	{
		str += GetObjectDef(*it) + ",";
	}
	str += t->area + ")";
	return str;
}

static map<string, string> tile_codes;
static int code_len;
static int next_code;

static const char *code_map = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

static void ProcessZLevel(ZLevel *zl)
{
	for(int y = 0; y < MAP_H; y++)
		for(int x = 0; x < MAP_W; x++)
			tile_codes[GetTileDef(&zl->tiles[x][y])] = "";
}

static string GenerateCode()
{
	string s;
	if(code_len >= 1) s.append(1, code_map[next_code % 52]);
	if(code_len >= 2) s.append(1, code_map[(next_code / 52) % 52]);
	if(code_len >= 3) s.append(1, code_map[(next_code / 52 / 52) % 52]);
	if(code_len >= 4) s.append(1, code_map[(next_code / 52 / 52 / 52) % 52]);
	++next_code;
	return s;
}

static void WriteZLevel(FILE *f, int z, ZLevel *zl)
{
	fprintf(f, "(1,1,%i) = {\"\n", z);
	for(int y = 0; y < MAP_H; y++)
	{
		for(int x = 0; x < MAP_W; x++)
			fprintf(f, tile_codes[GetTileDef(&zl->tiles[x][y])].c_str());
		fprintf(f, "\n");
	}
	fprintf(f, "\"}\n");
}

void WriteDMM()
{
	// first get all tile defs
	ProcessZLevel(&station);

	if(tile_codes.size() <= 52)
		code_len = 1;
	else if(tile_codes.size() <= 52*52)
		code_len = 2;
	else if(tile_codes.size() <= 52*52*52)
		code_len = 3;
	else
		code_len = 4;
	// may god help you if you have more than 7,311,616 codes

	next_code = 0;

	FILE *f = fopen("../maps/generated.dmm", "w");

	// assign codes to tile defs and write them
	for(map<string,string>::iterator it = tile_codes.begin(); it != tile_codes.end(); it++)
	{
		it->second = GenerateCode();
		fprintf(f, "\"%s\" = %s\n", it->second.c_str(), it->first.c_str());
	}

	WriteZLevel(f, 1, &station);

	fclose(f);
}