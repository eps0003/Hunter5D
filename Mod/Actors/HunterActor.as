#include "PhysicalActor.as"
#include "Gun.as"

shared class HunterActor : PhysicalActor
{
	private Gun@ gun;

	HunterActor(u16 id, CPlayer@ player, Vec3f position)
	{
		super(id, player, position);
		@gun = getGun(GunType::SMG, this);
	}

	u8 getType()
	{
		return EntityType::HunterActor;
	}

	void Update()
	{
		PhysicalActor::Update();
		gun.Update();
	}

	void Draw()
	{
		PhysicalActor::Draw();

		gun.Draw();

		if (isMyActor() && !g_videorecording)
		{
			DrawCrosshair(0, 8, 1, color_white);
		}
	}

	void SerializeInit(CBitStream@ bs)
	{
		PhysicalActor::SerializeInit(bs);
		gun.SerializeInit(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!PhysicalActor::deserializeInit(bs)) return false;

		Gun@ gun = getGun(GunType::SMG, this);
		if (!gun.deserializeInit(bs)) return false;
		@this.gun = gun;

		return true;
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		PhysicalActor::SerializeTickClient(bs);
		gun.SerializeTickClient(bs);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		if (!PhysicalActor::deserializeTickClient(bs)) return false;
		if (!gun.deserializeTickClient(bs)) return false;
		return true;
	}
}
