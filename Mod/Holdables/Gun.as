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

		ShootAction shootAction(this, actor);
		ReloadAction reloadAction(this);

		states.AddState(GunStates::Readying, GunReadying(readyTime));
		states.AddState(GunStates::Idle, GunIdle(shootAction, reloadAction));
		states.AddState(GunStates::Shooting, GunShooting(shootTime));
		states.AddState(GunStates::Reloading, GunReloading(shootAction, reloadAction, reloadTime));
		states.SetState(GunStates::Readying);
	}

	bool isAutomatic()
	{
		return true;
	}

	bool usesPellets()
	{
		return false;
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
	private ShootAction@ shootAction;
	private ReloadAction@ reloadAction;

	GunIdle(ShootAction@ shootAction, ReloadAction@ reloadAction)
	{
		@this.shootAction = shootAction;
		@this.reloadAction = reloadAction;
	}

	void Enter(StateMachine@ states)
	{
		print("Gun Idle!");
	}

	void Tick(StateMachine@ states)
	{
		if (shootAction.canShoot())
		{
			states.SetState(GunStates::Shooting);
		}
		else if (reloadAction.canReload())
		{
			states.SetState(GunStates::Reloading);
		}
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
		print("Gun Shooting!");
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
	private ShootAction@ shootAction;
	private ReloadAction@ reloadAction;
	private uint reloadTime;
	private Timer reloadTimer;

	GunReloading(ShootAction@ shootAction, ReloadAction@ reloadAction, uint reloadTime)
	{
		@this.shootAction = shootAction;
		@this.reloadAction = reloadAction;
		this.reloadTime = reloadTime;
	}

	void Enter(StateMachine@ states)
	{
		print("Gun Reloading!");
		reloadTimer.Start(reloadTime);
	}

	void Tick(StateMachine@ states)
	{
		if (reloadAction.canCancelReload() && shootAction.canShoot())
		{
			states.SetState(GunStates::Shooting);
		}

		if (reloadTimer.isDone())
		{
			if (reloadAction.reloadsIncrementally())
			{
				// TODO: Increment bullet count
				reloadTimer.Start(reloadTime);
			}
			else
			{
				// TODO: Set full bullet count
			}

			if (reloadAction.hasFinishedReloading())
			{
				states.SetState(GunStates::Idle);
			}
		}
	}
}

shared class ShootAction
{
	private Gun@ gun;
	private PhysicalActor@ actor;

	ShootAction(Gun@ gun, PhysicalActor@ actor)
	{
		@this.gun = gun;
		@this.actor = actor;
	}

	bool canShoot()
	{
		CBlob@ blob = actor.getBlob();
		return gun.isAutomatic() ? blob.isKeyPressed(key_action1) : blob.isKeyJustPressed(key_action1);
	}
}

shared class ReloadAction
{
	private Gun@ gun;

	ReloadAction(Gun@ gun)
	{
		@this.gun = gun;
	}

	bool canReload()
	{
		return getControls().isKeyPressed(KEY_KEY_R);
	}

	bool canCancelReload()
	{
		return gun.usesPellets();
	}

	bool reloadsIncrementally()
	{
		return gun.usesPellets();
	}

	bool hasFinishedReloading()
	{
		// TODO: Check ammo
		return true;
	}
}

shared enum GunStates
{
	Readying,
	Idle,
	Shooting,
	Reloading
}
