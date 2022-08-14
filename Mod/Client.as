#include "Camera.as"
#include "Map.as"

#define CLIENT_ONLY

Camera@ camera;
MapRenderer@ mapRenderer;

void onInit(CRules@ this)
{
	onRestart(this);
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
}

void onRestart(CRules@ this)
{
	@camera = Camera::getCamera();
	@mapRenderer = Map::getRenderer();
}

void Render(int id)
{
	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	camera.Render();
	mapRenderer.Render();

	SColor col = color_white;
	Vertex[] vertices = {
		Vertex(-1,  1, 10, 0, 0, col),
		Vertex( 1,  1, 10, 1, 0, col),
		Vertex( 1, -1, 10, 1, 1, col),
		Vertex(-1, -1, 10, 0, 1, col)
	};

	Render::SetBackfaceCull(false);
	Render::SetAlphaBlend(true);
	Render::RawQuads("pixel", vertices);
	Render::SetAlphaBlend(false);
	Render::SetBackfaceCull(true);
}
