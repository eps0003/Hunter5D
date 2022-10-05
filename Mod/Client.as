#include "Camera.as"
#include "Map.as"
#include "Entity.as"

#define CLIENT_ONLY

Camera@ camera;
MapRenderer@ mapRenderer;
EntityManager@ entityManager;
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

void onRender(CRules@ this)
{
	entityManager.DrawEntities();
}

void Render(int id)
{
	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	camera.Render();
	mapRenderer.Render();
	entityManager.RenderEntities();
}
