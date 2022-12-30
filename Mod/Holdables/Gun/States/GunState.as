#include "Timer.as"

shared enum GunState
{
	Readying,
	Idling,
	Shooting,
	Reloading
}

shared class GunReadying : State
{
	private Gun@ gun;
	private Timer readyTimer;

	GunReadying(Gun@ gun)
	{
		@this.gun = gun;
	}

	void Enter(StateMachine@ states)
	{
		readyTimer.Start(gun.readyTimeSeconds * getTicksASecond());
	}

	void Tick(StateMachine@ states)
	{
		if (readyTimer.isDone())
		{
			states.SetState(GunState::Idling);
		}
	}
}

shared class GunIdling : State
{
	private Gun@ gun;

	GunIdling(Gun@ gun)
	{
		@this.gun = gun;
	}

	void Tick(StateMachine@ states)
	{
		if (gun.shootHandler.isShootKeyPressed() && gun.shootHandler.canShoot() )
		{
			states.SetState(GunState::Shooting);
		}
		else if (gun.ammoHandler.isReloadKeyPressed() && gun.ammoHandler.canReload())
		{
			states.SetState(GunState::Reloading);
		}
	}
}

shared class GunShooting : State
{
	private Gun@ gun;
	private Timer shootTimer;

	GunShooting(Gun@ gun)
	{
		@this.gun = gun;
	}

	void Enter(StateMachine@ states)
	{
		gun.shootHandler.Shoot();
		shootTimer.Start(gun.shootHandler.getFireRate());
	}

	void Tick(StateMachine@ states)
	{
		if (shootTimer.isDone())
		{
			states.SetState(GunState::Idling);
		}
	}
}

shared class GunReloading : State
{
	private Gun@ gun;
	private Timer reloadTimer;

	GunReloading(Gun@ gun)
	{
		@this.gun = gun;
	}

	void Enter(StateMachine@ states)
	{
		reloadTimer.Start(gun.ammoHandler.getReloadTime());
	}

	void Tick(StateMachine@ states)
	{
		if (gun.ammoHandler.canCancelReload() && gun.shootHandler.canShoot())
		{
			states.SetState(GunState::Shooting);
		}

		if (reloadTimer.isDone())
		{
			gun.ammoHandler.Reload();

			if (gun.ammoHandler.hasFinishedReloading())
			{
				states.SetState(GunState::Idling);
			}
			else
			{
				reloadTimer.Start(gun.ammoHandler.getReloadTime());
			}
		}
	}
}
