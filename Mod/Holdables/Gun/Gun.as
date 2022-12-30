#include "StateMachine.as"
#include "GunStates.as"
#include "GunActions.as"

shared class Gun
{
	private PhysicalActor@ actor;
	private StateMachine states;

	private uint readyTime = 0.5f * getTicksASecond();
	private uint shootTime = 0.1f * getTicksASecond();
	private uint reloadTime = 1 * getTicksASecond();

	private uint ammo = getClipSize();
	private uint reserveAmmo = getClipSize() * 2;

	Gun(PhysicalActor@ actor)
	{
		@this.actor = actor;

		ShootAction shootAction(this, actor);
		ReloadAction reloadAction(this);

		states.AddState(GunStates::Readying, GunReadying(readyTime));
		states.AddState(GunStates::Idling, GunIdling(shootAction, reloadAction));
		states.AddState(GunStates::Shooting, GunShooting(shootAction, shootTime));
		states.AddState(GunStates::Reloading, GunReloading(shootAction, reloadAction, reloadTime));
		states.SetState(GunStates::Readying);
	}

	bool isAutomatic()
	{
		return true;
	}

	bool isMagazineFed()
	{
		return true;
	}

	uint getClipSize()
	{
		return 24;
	}

	uint getAmmo()
	{
		return ammo;
	}

	uint getReserveAmmo()
	{
		return reserveAmmo;
	}

	bool hasAmmo()
	{
		return getAmmo() > 0;
	}

	bool hasReserveAmmo()
	{
		return getReserveAmmo() > 0;
	}

	bool hasFullClip()
	{
		return getAmmo() >= getClipSize();
	}

	bool canReload()
	{
		return !hasFullClip() && hasReserveAmmo();
	}

	bool canShoot()
	{
		return hasAmmo();
	}

	void Shoot()
	{
		if (!canShoot()) return;

		// Raycast entities

		// Damage entities

		ammo--;
	}

	void Reload()
	{
		if (!canReload()) return;

		int ammoToReload = isMagazineFed()
			? Maths::Min(getClipSize() - getAmmo(), getReserveAmmo())
			: 1;

		ammo += ammoToReload;
		reserveAmmo -= ammoToReload;
	}

	void Update()
	{
		if (actor.isMyActor())
		{
			states.Update();
		}
	}

	void Draw()
	{
		if (actor.isMyActor() && !g_videorecording)
		{
			GUI::DrawText("Ammo: " + getAmmo() + " / " + getReserveAmmo(), Vec2f(10, 30), color_white);
			GUI::DrawText("State: " + getCurrentStateName(), Vec2f(10, 45), color_white);
		}
	}

	private string getCurrentStateName()
	{
		if (states.isState(GunStates::Readying))
			return "Readying";
		if (states.isState(GunStates::Idling))
			return "Idling";
		if (states.isState(GunStates::Shooting))
			return "Shooting";
		if (states.isState(GunStates::Reloading))
			return "Reloading";
		return "Unknown";
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
