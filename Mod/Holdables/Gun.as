#include "StateMachine.as"
#include "Timer.as"

shared class Gun
{
	private PhysicalActor@ actor;
	private StateMachine states;

	private uint readyTime = 1 * getTicksASecond();
	private uint shootTime = 0.2f * getTicksASecond();
	private uint reloadTime = 2 * getTicksASecond();

	Gun(PhysicalActor@ actor)
	{
		@this.actor = actor;

		states.AddState(GunStates::Readying, GunReadying(readyTime));
		states.AddState(GunStates::Idle, GunIdle());
		states.AddState(GunStates::Shooting, GunShooting(shootTime));
		states.AddState(GunStates::Reloading, GunReloading(reloadTime));
		states.SetState(GunStates::Readying);
	}

	void Update()
	{
		if (actor.isMyActor())
		{
			states.Update();
		}
	}

	void SerializeInit(CBitStream@ bs)
	{
		states.SerializeInit(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return states.deserializeInit(bs);
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		states.SerializeTick(bs);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		return states.deserializeTick(bs);
	}
}

shared class GunReadying : State
{
	private uint readyTime;
	private Timer readyTimer;

	GunReadying(uint readyTime)
	{
		this.readyTime = readyTime;
	}

	void Enter(StateMachine@ states)
	{
		readyTimer.Start(readyTime);
	}

	void Tick(StateMachine@ states)
	{
		if (readyTimer.isDone())
		{
			states.SetState(GunStates::Idle);
		}
	}
}

shared class GunIdle : State
{
	private bool automatic;

	GunIdle(bool automatic)
	{
		this.automatic = automatic;
	}

	void Enter(StateMachine@ states)
	{
		print("Gun Idle!");
	}
}

shared class GunShooting : State
{
	private uint shootTime;
	private Timer shootTimer;

	GunShooting(uint shootTime)
	{
		this.shootTime = shootTime;
	}

	void Enter(StateMachine@ states)
	{
		shootTimer.Start(shootTime);
	}

	void Tick(StateMachine@ states)
	{
		if (shootTimer.isDone())
		{
			states.SetState(GunStates::Idle);
		}
	}
}

shared class GunReloading : State
{
	private uint reloadTime;
	private bool pellets;
	private Timer reloadTimer;

	GunReloading(uint reloadTime, bool pellets = false)
	{
		this.reloadTime = reloadTime;
	}

	void Enter(StateMachine@ states)
	{
		reloadTimer.Start(reloadTime);
	}

	void Tick(StateMachine@ states)
	{
		if (reloadTimer.isDone())
		{
			if (pellets)
			{
				// TODO: Increment bullet count
				reloadTimer.Start(reloadTime);
			}
			else
			{
				// TODO: Set full bullet count
			}

			// TODO: check full bullet count
			if (true)
			{
				states.SetState(GunStates::Idle);
				return;
			}
		}
	}
}

shared enum GunStates
{
	Readying,
	Idle,
	Shooting,
	Reloading
}
