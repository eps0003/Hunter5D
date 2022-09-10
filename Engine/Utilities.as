#include "Maths.as"

shared u16 getUniqueId()
{
	return getRules().add_u16("_id", 1);
}

shared bool saferead_player(CBitStream@ bs, CPlayer@ &out player)
{
	u16 id;
	if (!bs.saferead_netid(id)) return false;

	@player = getPlayerByNetworkId(id);
	return player !is null;
}

shared bool isLocalHost()
{
	return isClient() && isServer();
}

shared bool isTickPaused()
{
	return isLocalHost() && Menu::getMainMenu() !is null;
}

shared string trimFileExtension(string fileName)
{
	return fileName.substr(0, fileName.findLast("."));
}

shared string formatDuration(float duration, bool showMilliseconds = false)
{
	s8 sign = Maths::Sign(duration);
	float totalSeconds = Maths::Abs(duration) / getTicksASecond();
	uint hours = totalSeconds / 3600;
	totalSeconds %= 3600;
	u8 minutes = totalSeconds / 60;
	u8 seconds = totalSeconds % 60;
	totalSeconds %= 1;
	u16 milliseconds = totalSeconds * 1000;

	string text = hours + ":" + formatInt(minutes, "0", 2) + ":" + formatInt(seconds, "0", 2);

	if (showMilliseconds)
	{
		text += "." + formatInt(milliseconds, "0", 3);
	}

	if (sign < 0)
	{
		text = "-" + text;
	}

	return text;
}

shared bool isNextMap()
{
	return getRules().get_bool("nextmap");
}

shared bool isRestartMap()
{
	return !isNextMap();
}

shared void RestartMap()
{
	LoadMap(getMap().getMapName());
}

shared float Vec2f_cross(Vec2f a, Vec2f b)
{
	return a.x * b.y - a.y * b.x;
}
