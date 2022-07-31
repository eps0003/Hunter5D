namespace Config
{
	shared ConfigFile@ getConfig()
	{
		ConfigFile@ cfg;
		if (!getRules().get("config", @cfg))
		{
			@cfg = ConfigFile();
			cfg.loadFile("../Cache/" + Config::getConfigName());
			getRules().set("config", @cfg);
		}
		return cfg;
	}

	shared void SaveConfig(ConfigFile cfg)
	{
		cfg.saveFile(Config::getConfigName());
	}

	shared string getConfigName()
	{
		return sv_gamemode + ".cfg";
	}

	shared void ResetConfig()
	{
		ConfigFile cfg;
		getRules().set("config", cfg);
		SaveConfig(cfg);
	}
}
