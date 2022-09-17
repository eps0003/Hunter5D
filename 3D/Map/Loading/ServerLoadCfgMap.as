#include "Loading.as"
#include "Map.as"
#include "MapGenerator.as"

shared class ServerLoadCfgMap : ServerLoadStep
{
	uint blocksPerTick = 8000;

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

	string chunk;
	uint value;
	SColor block;

	Map@ map = Map::getMap();

	ServerLoadCfgMap(string mapPath)
	{
		super("Generating map...");
		this.mapPath = mapPath;

		// Cache base64 values in dictionary
		for (uint i = 0; i < base64Chars.size(); i++)
		{
			string char = base64Chars.substr(i, 1);
			base64Values.set(char, i);
		}
	}

	private uint parseBase64(string str)
	{
		uint output = 0;
		uint index = 0;
		uint val;

		for (int i = str.size() - 1; i >= 0; i--)
		{
			string char = str.substr(i, 1);
			base64Values.get(char, val);

			output += val << index;
			index += 6;
		}

		return output;
	}

	void Init()
	{
		if (!mapCfg.loadFile(mapPath))
		{
			error("Unable to find map to load: " + mapPath);
			printTrace();
			return;
		}

		data = mapCfg.read_string("data");

		int width = parseBase64(data.substr(0, 2));
		int height = parseBase64(data.substr(2, 2));
		int depth = parseBase64(data.substr(4, 2));

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
			if (++count > blocksPerTick)
			{
				return;
			}

			if (fillCount == 0)
			{
				if (data.substr(dataIndex, 1) == "-")
				{
					// Air
					chunk = data.substr(dataIndex + 1, data.find("-", dataIndex + 1) - dataIndex - 1);
					mapIndex += chunk == "" ? 1 : parseBase64(chunk) + 2;
					dataIndex += chunk.size() + 2;
				}
				else if (data.substr(dataIndex, 1) == "!")
				{
					// Filler
					chunk = data.substr(dataIndex + 1, data.find("!", dataIndex + 1) - dataIndex - 1);
					fillCount = chunk == "" ? 1 : parseBase64(chunk) + 2;
					dataIndex += chunk.size() + 2;
				}
				else
				{
					// Block
					chunk = data.substr(dataIndex, 4);
					block = parseBase64(chunk);
					block.setAlpha(255);

					map.SetBlockInit(mapIndex++, block);

					dataIndex += 4;
				}
			}

			if (fillCount > 0)
			{
				map.SetBlockInit(mapIndex++, fillColor);
				fillCount--;
			}
		}

		complete = true;
		print("Generated map!");
		getRules().AddScript("MapHooksServer.as");
	}
}
