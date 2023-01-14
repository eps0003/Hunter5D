#include "IEntitySyncer.as"
#include "Entity.as"

shared class EntitySyncer : IEntitySyncer
{
	private IEntityManager@ entityManager;
	private dictionary packets;

	EntitySyncer()
	{
		@entityManager = Entity::getManager();
	}

	void Sync()
	{
		if (getPlayerCount() == 0 || !isServer()) return;

		IEntity@[] entities = entityManager.getEntities();
		for (uint i = 0; i < entities.size(); i++)
		{
			IEntity@ entity = entities[i];

			CBitStream bs;
			entity.SerializeTick(bs);
			Command::Send("sync entity", bs, true);
		}
	}

	void Receive()
	{
		if (getPlayerCount() == 0 || isServer()) return;

		IEntity@[] entities = entityManager.getEntities();
		for (uint i = 0; i < entities.size(); i++)
		{
			IEntity@ entity = entities[i];

			string packetKey = "" + entity.getId();
			CBitStream@ bs;
			if (!packets.get(packetKey, @bs)) continue;

			bs.ResetBitIndex();
			entity.deserializeTick(bs);
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
