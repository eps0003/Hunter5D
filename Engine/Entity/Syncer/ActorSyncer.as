#include "IEntitySyncer.as"
#include "Actor.as"

shared class ActorSyncer : IEntitySyncer
{
	private IActorManager@ actorManager;
	private dictionary packets;

	ActorSyncer()
	{
		@actorManager = Actor::getManager();
	}

	void Sync()
	{
		IActor@ myActor = actorManager.getActor(getLocalPlayer());
		if (myActor is null) return;

		CBitStream bs;
		myActor.SerializeTickClient(bs);
		Command::Send("sync actor", bs, true);
	}

	void Receive()
	{
		IActor@[] actors = actorManager.getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			IActor@ actor = actors[i];
			if (actor.isMyActor()) continue;

			string packetKey = "" + actor.getId();
			CBitStream@ bs;
			if (!packets.get(packetKey, @bs)) continue;

			bs.ResetBitIndex();
			actor.deserializeTickClient(bs);
			packets.delete(packetKey);
		}
	}

	void DeserializePacket(CBitStream@ bs)
	{
		CBitStream bs2;
		bs2.writeBitStream(bs, bs.getBitIndex(), bs.getBitsUsed() - bs.getBitIndex());
		bs2.ResetBitIndex();

		u16 id;
		if (!bs.saferead_u16(id)) return;

		packets.set("" + id, bs2);
	}
}
