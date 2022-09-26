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
	dictionary base64Values;

	string substr;
	SColor block;

	// parseBase64()
	uint output;
	u8 val;
	uint i;

	Map@ map = Map::getMap();

	ServerLoadCfgMap(string mapPath)
	{
		super("Generating map...");
		this.mapPath = mapPath;

		// Cache base64 values in dictionary
		for (uint i = 0; i < base64Chars.size(); i++)
		{
			base64Values.set(base64Chars.substr(i, 1), i);
		}
	}

	private uint parseBase64(const uint &in index, const uint &in count)
	{
		output = 0;

		for (i = index; i < index + count; i++)
		{
			base64Values.get(data.substr(i, 1), val);
			output = (output << 6) + val;
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
				substr = data.substr(dataIndex, 1);

				if (substr == "-")
				{
					// Air
					mapIndex += parseBase64(dataIndex + 1, 4) + 1;
					dataIndex += 5;
					count++;
				}
				else if (substr == "!")
				{
					// Filler
					fillCount = parseBase64(dataIndex + 1, 4) + 1;
					dataIndex += 5;
					count++;
				}
				else
				{
					// Block
					block = parseBase64(dataIndex, 4);
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

		complete = true;
		print("Generated map! " + formatDuration(getGameTime() - startTick, true));
		getRules().AddScript("MapHooksServer.as");
	}
}
