#include "Loading.as"
#include "Map.as"
#include "MapGenerator.as"

shared class ServerLoadCfgMap : ServerLoadStep
{
	uint blocksPerTick = 40000;

	uint startTick;

	uint mapIndex = 0;
	uint dataIndex = 0;
	uint dataSize = 0;

	uint fillCount = 0;
	SColor fillColor(255, 103, 64, 30);

	string mapPath;
	ConfigFile mapCfg;
	string data;

	string base64Chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
	u8[] base64Values = array<u8>(256, 0);

	Map@ map = Map::getMap();

	ServerLoadCfgMap(string mapPath)
	{
		super("Generating map...");
		this.mapPath = mapPath;

		// Cache base64 values in an array
		for (uint i = 0; i < base64Chars.size(); i++)
		{
			base64Values[base64Chars[i]] = i;
		}
	}

	private uint parseBase64(uint index, uint count)
	{
		uint output = 0;

		for (uint i = index; i < index + count; i++)
		{
			output = (output << 6) + base64Values[data[i]];
		}

		return output;
	}

	void Init()
	{
		startTick = getGameTime();

		if (!mapCfg.loadFile(mapPath))
		{
			error("Unable to find map to load: " + mapPath);
			printTrace();
			return;
		}

		data = mapCfg.read_string("data");

		u16 width = parseBase64(0, 2);
		u16 height = parseBase64(2, 2);
		u16 depth = parseBase64(4, 2);

		map.Init(Vec3f(width, height, depth));

		data = data.substr(6);
		dataSize = data.size();
	}

	void Load()
	{
		uint count = 0;

		progress = dataIndex / float(dataSize);

		while (dataIndex < dataSize)
		{
			if (count > blocksPerTick)
			{
				return;
			}

			if (fillCount == 0)
			{
				u8 ascii = data[dataIndex];

				if (ascii == 45) // "-"
				{
					// Air
					mapIndex += parseBase64(dataIndex + 1, 4) + 1;
					dataIndex += 5;
					count++;
				}
				else if (ascii == 33) // "!"
				{
					// Filler
					fillCount = parseBase64(dataIndex + 1, 4) + 1;
					dataIndex += 5;
					count++;
				}
				else
				{
					// Block
					SColor block = parseBase64(dataIndex, 4);
					block.setAlpha(255);

					map.SetBlockInit(mapIndex++, block);

					dataIndex += 4;
					count += 2;
				}
			}

			if (fillCount > 0)
			{
				map.SetBlockInit(mapIndex++, fillColor);
				fillCount--;
				count++;
			}
		}

		// Cleanup
		base64Values.clear();
		data = "";

		complete = true;
		print("Generated map! " + formatDuration(getGameTime() - startTick, true));
		getRules().AddScript("MapHooksServer.as");
	}
}
