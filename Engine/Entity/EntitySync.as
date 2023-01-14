#include "Entity.as"
#include "Actor.as"
#include "EntitySyncer.as"
#include "ActorSyncer.as"
#include "PhysicsHandler.as"

IEntityManager@ entityManager;
IActorManager@ actorManager;
IEntitySyncer@ entitySyncer;
IEntitySyncer@ actorSyncer;
IPhysicsHandler@ physicsHandler;

void onInit(CRules@ this)
{
	Command::Add("create entity");
	Command::Add("sync entity");
	Command::Add("sync actor");
	Command::Add("remove entity");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();
	@actorManager = Actor::getManager();
	@entitySyncer = EntitySyncer();
	@actorSyncer = ActorSyncer();
	@physicsHandler = PhysicsHandler();
}

void onTick(CRules@ this)
{
	IEntity@[] entities = entityManager.getEntities();

	for (uint i = 0; i < entities.size(); i++)
	{
		entities[i].PreUpdate();
	}

	// Receive most up-to-date entity data
	entitySyncer.Receive();
	actorSyncer.Receive();

	for (uint i = 0; i < entities.size(); i++)
	{
		IEntity@ entity = entities[i];

		entity.Update();

		// Handle physics
		IPhysics@ physicsEntity = cast<IPhysics>(entity);
		if (physicsEntity !is null)
		{
			physicsHandler.Update(physicsEntity);
		}
	}

	for (uint i = 0; i < entities.size(); i++)
	{
		entities[i].PostUpdate();
	}

	// Sync updated entity data
	entitySyncer.Sync();
	actorSyncer.Sync();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	IEntity@[] entities = entityManager.getEntities();
	for (uint i = 0; i < entities.size(); i++)
	{
		IEntity@ entity = entities[i];

		CBitStream bs;
		bs.write_u8(entity.getType());
		entity.SerializeInit(bs);
		Command::Send("create entity", bs, player);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer() && actorManager.actorExists(player))
	{
		actorManager.RemoveActor(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && Command::equals(cmd, "create entity"))
	{
		u8 type;
		if (!params.saferead_u8(type)) return;

		IEntity@ entity = getEntity(type);
		if (entity is null)
		{
			error("Attempted to create entity with invalid type: " + type);
			return;
		}

		if (!entity.deserializeInit(params)) return;

		entityManager.AddEntity(entity);
	}
	else if (!isServer() && Command::equals(cmd, "sync entity"))
	{
		entitySyncer.DeserializePacket(params);
	}
	else if (Command::equals(cmd, "sync actor"))
	{
		actorSyncer.DeserializePacket(params);
	}
	else if (!isServer() && Command::equals(cmd, "remove entity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		entityManager.RemoveEntity(id);
	}
}
