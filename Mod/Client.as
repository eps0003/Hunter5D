#include "Camera.as"
#include "Map.as"
#include "Entity.as"

#define CLIENT_ONLY

Camera@ camera;
MapRenderer@ mapRenderer;
IEntityManager@ entityManager;
IEntity@[] entities;
uint renderId;

void onRestart(CRules@ this)
{
	Render::RemoveScript(renderId);
	this.RemoveScript(getCurrentScriptName());
}

void onInit(CRules@ this)
{
	@camera = Camera::getCamera();
	@mapRenderer = Map::getRenderer();
	@entityManager = Entity::getManager();

	renderId = Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
}

void onTick(CRules@ this)
{
	entities = entityManager.getEntities();
}

void onRender(CRules@ this)
{
	for (uint i = 0; i < entities.size(); i++)
	{
		entities[i].Draw();
	}
}

void Render(int id)
{
	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	camera.Render();
	mapRenderer.Render();

	for (uint i = 0; i < entities.size(); i++)
	{
		entities[i].Render();
	}
}
