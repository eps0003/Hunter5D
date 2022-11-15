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
	Render::addScript(Render::layer_posthud, "LoadingScreen.as", "Render", 0);
}

void onRestart(CRules@ this)
{
	@loadingManager = Loading::getManager();
	@rules = this;
	@driver = getDriver();
}

void onTick(CRules@ this)
{
	@step = loadingManager.getCurrentStep();
}

void Render(int id)
{
	if (loadingManager.isMyPlayerLoaded()) return;

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
	float progress = getPlaceboProgress(step.getProgress());

	Vec2f textDim;
	GUI::GetTextDimensions(text, textDim);

	Vec2f tl(center.x - halfWidth, center.y - textDim.y);
	Vec2f br(center.x + halfWidth, center.y + textDim.y);

	GUI::DrawProgressBar(tl, br, progress);
	GUI::DrawTextCentered(text, center, color_white);
}

float getPlaceboProgress(float progress)
{
	// Fast later (larger = stronger)
	// float placeboStrength = 2.0f;
	// return 1 - Maths::Pow(1 - progress, placeboStrength);

	// Fast initially (smaller = stronger)
	float placeboStrength = 0.5f;
	return Maths::Pow(progress, placeboStrength);

	// Custom curve with slight end bias (smaller = stronger)
	// float placeboStrength = 0.1f;
	// return (Maths::Pow(placeboStrength, progress) - 1) / (placeboStrength - 1);

	// Perfect curve (larger = stronger)
	// https://math.stackexchange.com/a/4277261
	// float placeboStrength = 1.5f;
	// return Maths::Pow(1 - Maths::Pow(1 - x, placeboStrength), 1.0f / placeboStrength);
}
