#include "Loading.as"
#include "Map.as"
#include "MapGenerator.as"

shared class ServerLoadCfgMap : ServerLoadStep
{
	uint blocksPerTick = 10000;

	uint mapIndex = 0;
	uint dataIndex = 0;
	uint dataSize = 0;

	string mapPath;
	ConfigFile mapCfg;
	string data;

	string base64Chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
	dictionary base64Values;

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

		for (int i = str.size() - 1; i >= 0; i--)
		{
			string char = str.substr(i, 1);

			uint val;
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

		Vec3f pos = map.indexToPos(mapIndex);

		while (dataIndex < dataSize)
		{
			if (++count > blocksPerTick)
			{
				return;
			}

			if (data.substr(dataIndex, 1) != "-")
			{
				// Block
				string chunk = data.substr(dataIndex, 4);
				uint val = parseBase64(chunk);

				SColor block(val);
				block.setAlpha(255);

				map.SetBlockInit(mapIndex++, pos.x, pos.y, pos.z, block);

				pos.x++;
				if (pos.x == 0)
				{
					pos.z++;
					if (pos.y == 0)
					{
						pos.y++;
					}
				}

				dataIndex += 4;
			}
			else
			{
				// Air
				int airIndex = data.find("-", dataIndex + 1);
				string chunk = data.substr(dataIndex + 1, airIndex - dataIndex - 1);
				int airCount = chunk == "" ? 1 : parseBase64(chunk) + 2;

				mapIndex += airCount;
				dataIndex += chunk.size() + 2;

				for (uint i = 0; i < airCount; i++)
				{
					pos.x++;
					if (pos.x == 0)
					{
						pos.z++;
						if (pos.y == 0)
						{
							pos.y++;
						}
					}
				}
			}
		}

		complete = true;
		print("Generated map!");
		getRules().AddScript("MapHooksServer.as");
	}
}
