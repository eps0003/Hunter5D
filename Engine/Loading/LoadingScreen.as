#include "Loading.as"

#define CLIENT_ONLY

LoadingManager@ loadingManager;
LoadStep@ step;

CRules@ rules;
Driver@ driver;
int renderId;

const SColor BACKGROUND_COLOR(255, 165, 189, 200);

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@loadingManager = Loading::getManager();
	@rules = this;
	@driver = getDriver();

	renderId = Render::addScript(Render::layer_posthud, "LoadingScreen.as", "Render", 0);
}

void onTick(CRules@ this)
{
	@step = loadingManager.getCurrentStep();

	if (loadingManager.isMyPlayerLoaded())
	{
		Render::RemoveScript(renderId);
		this.RemoveScript(getCurrentScriptName());
	}
}

void Render(int id)
{
	Vec2f screenDim = driver.getScreenDimensions();
	GUI::DrawRectangle(Vec2f_zero, screenDim, BACKGROUND_COLOR);

	DrawLoadingBar(rules);
}

void DrawLoadingBar(CRules@ this)
{
	if (step is null) return;

	Vec2f center = driver.getScreenCenterPos();
	uint halfWidth = getScreenWidth() * 0.4f;

	string text = step.getMessage();
	float progress = step.getProgress();

	Vec2f textDim;
	GUI::GetTextDimensions(text, textDim);

	Vec2f tl(center.x - halfWidth, center.y - textDim.y);
	Vec2f br(center.x + halfWidth, center.y + textDim.y);

	GUI::DrawProgressBar(tl, br, progress);
	GUI::DrawTextCentered(text, center, color_white);
}
