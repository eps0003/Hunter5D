#include "StateMachine.as"
#include "GunState.as"
#include "ShootHandlers.as"
#include "AmmoHandlers.as"
#include "GunBuilder.as"
#include "GunDirector.as"
#include "Guns.as"

shared class Gun
{
	Actor@ actor;

	u16 type;
	string name;
	uint magazineSize;
	float readyTimeSeconds;
	float reloadTimeSeconds;
	float fireRateSeconds;
	ShootHandler@ shootHandler;
	AmmoHandler@ ammoHandler;

	private StateMachine states;

	Gun(Actor@ actor)
	{
		@this.actor = actor;

		states.AddState(GunState::Readying, GunReadying(this));
		states.AddState(GunState::Idling, GunIdling(this));
		states.AddState(GunState::Shooting, GunShooting(this));
		states.AddState(GunState::Reloading, GunReloading(this));
		states.SetState(GunState::Readying);
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
			string ammoText = "Ammo: " + ammoHandler.getAmmo() + " / " + ammoHandler.getReserveAmmo();
			string stateText = "State: " + states.toString();

			GUI::DrawText(ammoText, Vec2f(10, 30), color_white);
			GUI::DrawText(stateText, Vec2f(10, 45), color_white);
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
