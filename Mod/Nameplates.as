#include "Actor.as"

#define CLIENT_ONLY

EntityManager@ entityManager;
Entity@[] entities;

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
		PhysicalActor@ actor = cast<PhysicalActor>(entities[i]);
		if (actor is null) continue;

		CPlayer@ player = actor.getPlayer();
		if (player.isMyPlayer()) continue;

		AABB@ collider = actor.getCollider();
		if (collider is null) continue;

		Vec3f worldPos = actor.interPosition + Vec3f(0.0f, collider.dim.y + 0.4f, 0.0f);
		if (!worldPos.isInFrontOfCamera()) continue;

		Vec2f screenPos = worldPos.projectToScreen();

		CTeam@ team = this.getTeam(player.getTeamNum());
		SColor nameColor = team !is null ? team.color : color_white;

		string health = "" + Maths::Ceil(actor.getHealthPercentage() * 100) + "%";
		SColor healthColor = SColor().getInterpolated_quadratic(SColor(255, 255, 0, 0), color_white, actor.getHealthPercentage());

		GUI::DrawTextCentered(player.getCharacterName(), screenPos - Vec2f(0.0f, 14.0f), nameColor);
		GUI::DrawTextCentered(health, screenPos, healthColor);
	}
}
