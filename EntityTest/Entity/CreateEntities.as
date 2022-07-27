#include "Entity1.as"
#include "Entity2.as"

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("create entity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		u8 type;
		if (!params.saferead_u8(type)) return;

		Entity@ entity = getEntity(id, type);
		if (entity is null)
		{
			error("Attempted to create entity with invalid type: " + type);
			return;
		}

		if (!entity.deserialize(params)) return;

		Entity::getManager().AddEntity(entity);
	}
}

shared Entity@ getEntity(u16 id, u8 type)
{
	switch (type)
	{
	case 0:
		return Entity1(id);
	case 1:
		return Entity2(id);
	}
	return null;
}