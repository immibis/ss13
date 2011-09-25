#include "dmm.h"
#include <stdio.h>
#include <fstream>

using namespace std;

struct MapObjectData
{
	string path;
	map<string, string> vars;
};
typedef list<MapObjectData*> MapCode;

template<class T> class CodeLookupTree
{
	T *table;
	int depth;
	unsigned int table_size;
	unsigned int get_path(const char *str)
	{
		unsigned int p = 0;
		while(*str)
		{
			p *= 52;
			if(*str <= 'Z')
				p += *str - 'A';
			else
				p += *str - 'a' + 26;
			++str;
		}
		return p;
	}
public:
	void init(int depth)
	{
		table_size = 1;
		for(int k = 0; k < depth; k++)
			table_size *= 52;
		table = new T[table_size];
		memset(table, 0, sizeof(T)*table_size);
	}
	CodeLookupTree() : table(NULL), depth(0), table_size(0) {}
	~CodeLookupTree()
	{
		delete [] table;
	}
	T get(const char *str)
	{
		return table[get_path(str)];
	}
	void put(const char *str, T val)
	{
		table[get_path(str)] = val;
	}
};

// modifies "text"
void ParseMapObjects(MapCode *objs, char *text)
{
	//LoadProfileBegin("ParseMapObjects");
	while(*text)
	{
		if(*text != '/')
		{
			printf("DMM format error in \"%s\" - expected /\n", text);
			break;
		}
		
		char *pStr = text;
		while(*pStr && *pStr != ',' && *pStr != '{')
			pStr++;

		MapObjectData *obj = new MapObjectData;

		if(*pStr == '{')
		{
			*pStr++ = '\0';
			obj->path = text;
			text = pStr;

			while(*text)
			{
				if(*text == '}')
				{
					++text;
					break;
				}
				pStr = text;
				while(*pStr && *pStr != ' ')
					++pStr;
				*pStr++ = '\0';
				string key = text;
				pStr += 2;
				text = pStr;
				
				string value;
				bool found_end = false;
				if(*text == '"')
				{
					pStr = text + 1;
					while(*pStr && *pStr != '"')
					{
						if(*pStr == '\\' && pStr[1])
							++pStr;
						++pStr;
					}
					if(*pStr)
						*pStr++ = '\0';
					if(*pStr == '}')
						found_end = true;
					if(*pStr)
						*pStr++ = '\0';
					value = "\"" + string(text + 1) + "\"";
					text = pStr;
				}
				else
				{
					while(*pStr && *pStr != ';' && *pStr != '}')
						++pStr;
					if(*pStr == '}')
						found_end = true;
					*pStr++ = '\0';
					value = text;
					text = pStr;
				}
				while(*text == ' ')
					++text;

				obj->vars[key] = value;
				if(found_end)
				{
					if(*text == ',')
						++text;
					break;
				}
			}
		}
		else if(*pStr)
		{
			*pStr++ = '\0';
			obj->path = text;
			text = pStr;
		}
		else
		{
			obj->path = text;
			text = pStr;
		}

		objs->insert(objs->end(), obj);
	}
	//LoadProfileEnd();
}

TileGroup *LoadTileGroup(const char *filename)
{
	int code_length = -1;
	int xsize = -1;
	int ysize = 0;
	int zsize = 0;
	streampos mapstart;
	CodeLookupTree<MapCode*> codes;

	map<string, int> missing_paths;

	{
		ifstream f(filename);
		if(!f.good())
		{
			printf("could not open %s\n", filename);
			return NULL;
		}
		code_length = -1;
		while(true)
		{
			string line;
			getline(f, line);
			if(line.length() == 0)
				break;
			if(line[0] != '"')
			{
				printf("map file syntax error in %s\n", filename);
				return NULL;
			}
			MapCode *code = new MapCode;
			string name = line.substr(1, line.find('"', 1) - 1);
			if(code_length == -1)
			{
				code_length = name.length();
				codes.init(code_length);
			}
			else if(code_length != name.length())
			{
				printf("map file error in %s (differing code lengths)\n", filename);
				return NULL;
			}
			{
				int lindex = line.find('(');
				int rindex = line.rfind(')');
				string objdata = line.substr(lindex + 1, rindex - lindex - 1);
				char *objdata_c = strdup(objdata.c_str());
				ParseMapObjects(code, objdata_c);
				free(objdata_c);
			}
			codes.put(name.c_str(), code);
		}

		while(true)
		{
			string line;
			getline(f, line);
			if(line == "(1,1,1) = {\"")
				break;
		}

		mapstart = f.tellg();

		while(!f.eof())
		{
			string line;
			getline(f, line);
			if(line == "\"}")
				zsize++;
			if(zsize == 0)
			{
				ysize ++;
				if(xsize == -1)
					xsize = line.length()/code_length;
				else if(xsize != line.length()/code_length)
				{
					printf("map file error in %s (different map line lengths)\n", filename);
					return NULL;
				}
			}
		}
	}

	// for some reason you can't just seek back to the middle of the file after hitting EOF,
	// you need to open it again

	ifstream f(filename);

	TileGroup *tg = new TileGroup(xsize, ysize);
	
	f.seekg(mapstart);

	int y = 0;

	while(!f.eof())
	{
		string line;
		getline(f, line);
		if(line == "\"}")
			break;
		if(line[0] == '(' || line == "")
			continue;
		for(int x = 0; x < xsize; x++)
		{
			string code = line.substr(x * code_length, code_length);
			MapCode &c = *codes.get(code.c_str());
			MapCode::iterator it = c.begin();
			
			Tile *tile = &tg->tiles[x + y*tg->width];
			
			while(it != c.end())
			{
				MapObjectData &o = *(*it++);
				const char *path_c = o.path.c_str();

				if(o.path.substr(0,5) == "/area")
				{
					tile->area = o.path;
				}
				else
				{
					Object *obj = new Object;
					tile->objects.push_back(obj);

					obj->attrib = o.vars;
					obj->path = o.path;

					if(o.path.substr(0,5) == "/turf")
					{
						tile->objects.remove(tile->turf);
						delete tile->turf;
						tile->turf = obj;
					}
				}
			}
		}
		y++;
	}
	return tg;
}