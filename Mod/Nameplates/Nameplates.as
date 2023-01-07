#include "Entity.as"

#define CLIENT_ONLY

EntityManager@ entityManager;
IEntity@[] entities;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();
}

void onTick(CRules@ this)
{
	entities = entityManager.getEntities();
}

void onRender(CRules@ this)
{
	for (uint i = 0; i < entities.size(); i++)
	{
		INameplate@ nameplate = cast<INameplate>(entities[i]);
		if (nameplate is null) continue;

		if (!nameplate.isNameplateVisible()) continue;

		string text = nameplate.getNameplateText();
		Vec2f screenPos = nameplate.getNameplatePosition().projectToScreen();
		SColor color = nameplate.getNameplateColor();

		GUI::DrawTextCentered(text, screenPos, color);
	}
}
