#include "Timer.as"

shared enum GunStates
{
	Readying,
	Idling,
	Shooting,
	Reloading
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
			states.SetState(GunStates::Idling);
		}
	}
}

shared class GunIdling : State
{
	private ShootAction@ shootAction;
	private ReloadAction@ reloadAction;

	GunIdling(ShootAction@ shootAction, ReloadAction@ reloadAction)
	{
		@this.shootAction = shootAction;
		@this.reloadAction = reloadAction;
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
	ShootAction@ shootAction;
	private uint shootTime;
	private Timer shootTimer;

	GunShooting(ShootAction@ shootAction, uint shootTime)
	{
		@this.shootAction = shootAction;
		this.shootTime = shootTime;
	}

	void Enter(StateMachine@ states)
	{
		shootAction.Shoot();
		shootTimer.Start(shootTime);
	}

	void Tick(StateMachine@ states)
	{
		if (shootTimer.isDone())
		{
			states.SetState(GunStates::Idling);
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
			reloadAction.Reload();

			if (reloadAction.hasFinishedReloading())
			{
				states.SetState(GunStates::Idling);
			}
			else if (reloadAction.reloadsIncrementally())
			{
				reloadTimer.Start(reloadTime);
			}
		}
	}
}
