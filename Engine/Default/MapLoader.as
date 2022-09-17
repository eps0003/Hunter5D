bool LoadMap(CMap@ map, const string&in fileName)
{
	if (!isServer())
	{
		map.CreateTileMap(0, 0, 1.0f, "Pixel.png");
	}
	else
	{
		map.CreateTileMap(298, 105, 1.0f, "Pixel.png");
	}
	return true;
}
