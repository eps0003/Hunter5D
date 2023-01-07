#include "PhysicalActor.as"
#include "HeldBlock.as"

shared class SandboxActor : PhysicalActor
{
	HeldBlock@ heldBlock;

	SandboxActor(u16 id, CPlayer@ player, Vec3f position)
	{
		super(id, player, position);
		@heldBlock = HeldBlock(this);
	}

	u8 getType()
	{
		return EntityType::SandboxActor;
	}

	void Update()
	{
		PhysicalActor::Update();
		heldBlock.Update();
	}

	void Draw()
	{
		PhysicalActor::Draw();
		heldBlock.Draw();
	}

	void SerializeInit(CBitStream@ bs)
	{
		PhysicalActor::SerializeInit(bs);
		heldBlock.SerializeInit(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		@heldBlock = HeldBlock(this);

		if (!PhysicalActor::deserializeInit(bs)) return false;
		if (!heldBlock.deserializeInit(bs)) return false;
		return true;
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		PhysicalActor::SerializeTickClient(bs);
		heldBlock.SerializeTick(bs);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		if (!PhysicalActor::deserializeTickClient(bs)) return false;
		if (!heldBlock.deserializeTick(bs)) return false;
		return true;
	}
}
