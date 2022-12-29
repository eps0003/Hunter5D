shared class Timer
{
	private uint duration = 0;
	private uint endTime = 0;
	private bool running = false;

	void Start(uint duration)
	{
		this.duration = duration;
		endTime = getGameTime() + duration;
		running = true;
	}

	void Stop()
	{
		duration = 0;
		endTime = 0;
		running = false;
	}

	uint getTicksRemaining()
	{
		return Maths::Max(endTime - getGameTime(), 0);
	}

	uint getDuration()
	{
		return duration;
	}

	bool isRunning()
	{
		return running;
	}

	bool isStopped()
	{
		return !isRunning();
	}

	bool isDone()
	{
		return isRunning() && getGameTime() >= endTime;
	}
}
