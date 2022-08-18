#include "Camera.as"
#include "Map.as"

#define CLIENT_ONLY

Camera@ camera;
MapRenderer@ mapRenderer;

void onInit(CRules@ this)
{
	@camera = Camera::getCamera();
	@mapRenderer = Map::getRenderer();

	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
}

void onRestart(CRules@ this)
{
	this.RemoveScript(getCurrentScriptName());
}

void Render(int id)
{
	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	camera.Render();
	mapRenderer.Render();
}
