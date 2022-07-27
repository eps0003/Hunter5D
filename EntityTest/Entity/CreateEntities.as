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

		EntityManager@ entityManager = Entity::getManager();

		switch (type)
		{
			case 0:
				entityManager.AddEntity(Entity1(id));
				break;
			case 1:
				entityManager.AddEntity(Entity2(id));
				break;
			default:
				error("Attempted to create entity with invalid type " + type);
		}
	}
}
