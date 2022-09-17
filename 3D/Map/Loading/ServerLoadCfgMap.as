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

	Map@ map = Map::getMap();

	ServerLoadCfgMap(string mapPath)
	{
		super("Generating map...");
		this.mapPath = mapPath;
	}

	private uint parse_base64(string str)
	{
		uint output = 0;
		uint index = 0;

		for (int i = str.size() - 1; i >= 0; i--)
		{
			string char = str.substr(i, 1);
			uint val = base64Chars.find(char);
			output += val << (6 * index++);
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

		int width = parse_base64(data.substr(0, 2));
		int height = parse_base64(data.substr(2, 2));
		int depth = parse_base64(data.substr(4, 2));

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

			if (data.substr(dataIndex, 1) != "-")
			{
				// Block
				string chunk = data.substr(dataIndex, 4);
				uint val = parse_base64(chunk);

				SColor color(val);
				color.setAlpha(255);

				map.SetBlock(mapIndex++, color);

				dataIndex += 4;
			}
			else
			{
				// Air
				int airIndex = data.find("-", dataIndex + 1);
				string chunk = data.substr(dataIndex + 1, airIndex - dataIndex - 1);
				int airCount = chunk == "" ? 1 : parse_base64(chunk) + 2;
				mapIndex += airCount;

				dataIndex += chunk.size() + 2;
			}
		}

		complete = true;
		print("Generated map!");
		getRules().AddScript("MapHooksServer.as");
	}
}
