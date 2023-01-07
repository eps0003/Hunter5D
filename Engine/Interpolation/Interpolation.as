namespace Interpolation
{
	shared bool isEnabled()
	{
		return !v_capped;
	}

	shared float getGameTime()
	{
		return isClient() && Interpolation::isEnabled()
			? getRules().get_f32("inter_game_time") :
			::getGameTime();
	}

	shared float getFrameTime()
	{
		return isClient() && Interpolation::isEnabled()
			? getRules().get_f32("inter_frame_time")
			: 1.0f;
	}
}
